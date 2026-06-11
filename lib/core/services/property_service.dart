import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/property_model.dart';

class PropertyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Unggah Properti Baru dengan Gambar ke Supabase Storage & Cloud Firestore
  Future<String?> tambahPropertiDenganGambar({
    required Property properti,
    required List<File> berkasGambar,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      
      // 1. Dapatkan/buat ID dokumen properti baru
      String idProperti = properti.idProperti;
      if (idProperti.isEmpty) {
        idProperti = _db.collection('tb_properti').doc().id;
      }
      
      final List<String> listUrl = [];
      final List<PropertyPhoto> listFoto = [];

      // 2. Iterasi berkasGambar dan unggah ke Supabase Storage
      for (var file in berkasGambar) {
        final String namaFile = file.path.split('/').last.split('\\').last;
        final String pathFolder = '$idProperti/$namaFile';
        
        // Unggah
        await supabase.storage.from('properti_images').upload(
          pathFolder,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );
        
        // Ambil URL publik
        final String downloadUrl = supabase.storage.from('properti_images').getPublicUrl(pathFolder);
        listUrl.add(downloadUrl);
        
        // Siapkan objek foto properti untuk tb_foto_properti
        final idFoto = _db.collection('tb_foto_properti').doc().id;
        listFoto.add(PropertyPhoto(
          idFoto: idFoto,
          idProperti: idProperti,
          urlFile: downloadUrl,
          namaFile: namaFile,
          createdAt: DateTime.now(),
        ));
      }

      // 3. Masukkan list URL ke metadata properti
      final Property propertiFinal = Property(
        idProperti: idProperti,
        idProyek: properti.idProyek,
        kodeUnit: properti.kodeUnit,
        tipeRumah: properti.tipeRumah,
        luasTanah: properti.luasTanah,
        luasBangunan: properti.luasBangunan,
        kamarTidur: properti.kamarTidur,
        kamarMandi: properti.kamarMandi,
        harga: properti.harga,
        statusProperti: properti.statusProperti,
        createdAt: properti.createdAt,
        title: properti.title,
        description: properti.description,
        address: properti.address,
        location: properti.location,
        agentId: properti.agentId,
        brId: properti.brId,
        imageUrls: listUrl,
        latitude: properti.latitude,
        longitude: properti.longitude,
      );

      // 4. Lakukan operasi write / batch write ke Cloud Firestore
      final WriteBatch batch = _db.batch();
      
      final DocumentReference propRef = _db.collection('tb_properti').doc(idProperti);
      batch.set(propRef, propertiFinal.toFirestore());
      
      for (var foto in listFoto) {
        final DocumentReference fotoRef = _db.collection('tb_foto_properti').doc(foto.idFoto);
        batch.set(fotoRef, foto.toFirestore());
      }
      
      await batch.commit();
      return idProperti;
    } catch (e) {
      print("Error tambahPropertiDenganGambar: $e");
      rethrow;
    }
  }

  // Tambah Properti Baru
  Future<String?> addProperty(Property property) async {
    try {
      DocumentReference doc = await _db.collection('tb_properti').add(property.toFirestore());
      return doc.id;
    } catch (e) {
      print("Error add property: $e");
      return null;
    }
  }

  // Update Properti (Real-time)
  Future<bool> updateProperty(Property property) async {
    try {
      await _db.collection('tb_properti').doc(property.idProperti).update(property.toFirestore());
      print("Property updated successfully: ${property.idProperti}");
      return true;
    } catch (e) {
      print("Error update property: $e");
      return false;
    }
  }

  // Update Properti dengan Gambar baru (Overwriting/deleting old images)
  Future<bool> updatePropertiDenganGambar({
    required Property properti,
    required List<File> berkasGambar,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final String idProperti = properti.idProperti;
      final List<String> listUrl = [];
      final List<PropertyPhoto> listFoto = [];

      if (berkasGambar.isNotEmpty) {
        // 1. Bersihkan gambar lama di Supabase Storage untuk menghemat kuota
        try {
          final List<FileObject> files = await supabase.storage.from('properti_images').list(path: idProperti);
          if (files.isNotEmpty) {
            final List<String> pathsToDelete = files.map((file) => '$idProperti/${file.name}').toList();
            await supabase.storage.from('properti_images').remove(pathsToDelete);
            print("Successfully deleted old files from storage: $pathsToDelete");
          }
        } catch (storageError) {
          print("Note: Could not delete old files or none existed: $storageError");
        }

        // 2. Upload gambar baru
        for (var file in berkasGambar) {
          final String namaFile = file.path.split('/').last.split('\\').last;
          final String pathFolder = '$idProperti/$namaFile';
          
          await supabase.storage.from('properti_images').upload(
            pathFolder,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
          
          final String downloadUrl = supabase.storage.from('properti_images').getPublicUrl(pathFolder);
          listUrl.add(downloadUrl);
          
          final idFoto = _db.collection('tb_foto_properti').doc().id;
          listFoto.add(PropertyPhoto(
            idFoto: idFoto,
            idProperti: idProperti,
            urlFile: downloadUrl,
            namaFile: namaFile,
            createdAt: DateTime.now(),
          ));
        }

        // 3. Update database Firestore (Hapus foto lama, simpan foto baru, update properti)
        final WriteBatch batch = _db.batch();
        
        final oldPhotos = await _db.collection('tb_foto_properti').where('id_properti', isEqualTo: idProperti).get();
        for (var doc in oldPhotos.docs) {
          batch.delete(doc.reference);
        }

        for (var foto in listFoto) {
          final DocumentReference fotoRef = _db.collection('tb_foto_properti').doc(foto.idFoto);
          batch.set(fotoRef, foto.toFirestore());
        }

        final updatedPropWithImages = properti.copyWith(imageUrls: listUrl);
        final DocumentReference propRef = _db.collection('tb_properti').doc(idProperti);
        batch.update(propRef, updatedPropWithImages.toFirestore());

        await batch.commit();
      } else {
        // Jika tidak ada gambar baru, update document properti biasa
        await _db.collection('tb_properti').doc(idProperti).update(properti.toFirestore());
      }
      return true;
    } catch (e) {
      print("Error updatePropertiDenganGambar: $e");
      return false;
    }
  }

  // Ambil Semua Properti (Real-time)
  Stream<List<Property>> getProperties() {
    return _db.collection('tb_properti')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Property.fromFirestore(doc))
            .toList());
  }

  // Ambil Properti berdasarkan Agent
  Stream<List<Property>> getAgentProperties(String agentId) {
    return _db.collection('tb_properti')
        .where('agentId', isEqualTo: agentId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Property.fromFirestore(doc))
            .toList());
  }

  // Hapus Properti dari Firestore & Supabase Storage
  Future<bool> deleteProperty(String propertyId) async {
    try {
      final supabase = Supabase.instance.client;

      // 1. Hapus berkas gambar dari Supabase Storage
      try {
        final List<FileObject> files = await supabase.storage.from('properti_images').list(path: propertyId);
        if (files.isNotEmpty) {
          final List<String> pathsToDelete = files.map((file) => '$propertyId/${file.name}').toList();
          await supabase.storage.from('properti_images').remove(pathsToDelete);
          print("Deleted storage files for property $propertyId: $pathsToDelete");
        }
      } catch (e) {
        print("Note: Error deleting storage files or none existed: $e");
      }

      // 2. Operasi Firestore (Hapus tb_foto_properti & tb_properti)
      final WriteBatch batch = _db.batch();

      final photosQuery = await _db.collection('tb_foto_properti').where('id_properti', isEqualTo: propertyId).get();
      for (var doc in photosQuery.docs) {
        batch.delete(doc.reference);
      }

      final propRef = _db.collection('tb_properti').doc(propertyId);
      batch.delete(propRef);

      await batch.commit();
      print("Successfully deleted property and associated photos from Firestore: $propertyId");
      return true;
    } catch (e) {
      print("Error in deleteProperty: $e");
      return false;
    }
  }
}
import 'dart:io';

class Buku {
  String judul;
  bool dipinjam;
  String peminjam;
  Buku? bukuBerikutnya;

  Buku(this.judul, {this.dipinjam = false, this.peminjam = ''});
}

class Perpustakaan {
  Buku? bukuPertama;

  void tambahBuku(String judul, {bool dipinjam = false, String peminjam = ''}) {
    
    if (judul.trim().isEmpty) return;

    Buku bukuBaru = Buku(judul, dipinjam: dipinjam, peminjam: peminjam);
    if (bukuPertama == null) {
      bukuPertama = bukuBaru;
    } else {
      Buku? bukuSaatIni = bukuPertama;
      while (bukuSaatIni?.bukuBerikutnya != null) {
        bukuSaatIni = bukuSaatIni?.bukuBerikutnya;
      }
      bukuSaatIni?.bukuBerikutnya = bukuBaru;
    }
  }

  Buku? cariBuku(String judul) {
    Buku? bukuSaatIni = bukuPertama;
    while (bukuSaatIni != null) {
      if (bukuSaatIni.judul.toLowerCase() == judul.toLowerCase()) {
        return bukuSaatIni;
      }
      bukuSaatIni = bukuSaatIni.bukuBerikutnya;
    }
    return null;
  }

  void perbaruiStatusBuku(String judul, bool dipinjam, {String peminjam = ''}) {
    Buku? buku = cariBuku(judul);
    if (buku != null) {
      buku.dipinjam = dipinjam;
      buku.peminjam = peminjam;
    }
  }

  void tampilkanBuku({bool hanyaTersedia = false}) {
    Buku? bukuSaatIni = bukuPertama;
    bool ditemukanBuku = false;
    while (bukuSaatIni != null) {
      if (!hanyaTersedia || !bukuSaatIni.dipinjam) {
        print('${bukuSaatIni.judul} (${bukuSaatIni.dipinjam ? 'Dipinjam oleh ' + bukuSaatIni.peminjam : 'Tersedia'})');
        ditemukanBuku = true;
      }
      bukuSaatIni = bukuSaatIni.bukuBerikutnya;
    }
    if (!ditemukanBuku) {
      print(hanyaTersedia
          ? "Tidak ada buku yang tersedia."
          : "Tidak ada buku dalam daftar.");
    }
  }
}

class HistoriPeminjaman {
  final List<String> _histori = [];

  void tambahHistori(String data) => _histori.add(data);
  void tampilkanHistori() => _histori.reversed.forEach(print);
}

void main() {
  Perpustakaan perpustakaan = Perpustakaan();
  HistoriPeminjaman historiPeminjaman = HistoriPeminjaman();

  muatStatusPeminjamanBuku(perpustakaan);

  print("\nMasukkan nama Anda untuk meminjam atau mengembalikan buku:");
  String peminjam = stdin.readLineSync() ?? '';

  while (true) {
    print("\nDaftar Buku yang Tersedia:");
    perpustakaan.tampilkanBuku(hanyaTersedia: true);

    print("\nMasukkan nama buku yang ingin dipinjam atau dikembalikan (atau 'exit' untuk selesai):");
    String input = stdin.readLineSync() ?? '';

    if (input == 'exit') break;

    Buku? buku = perpustakaan.cariBuku(input);
    if (buku != null) {
      if (!buku.dipinjam) {
        perpustakaan.perbaruiStatusBuku(input, true, peminjam: peminjam);
        historiPeminjaman.tambahHistori("$peminjam meminjam $input");
        print("\n$input berhasil dipinjam oleh $peminjam.");
      } else if (buku.peminjam == peminjam) {
        perpustakaan.perbaruiStatusBuku(input, false);
        historiPeminjaman.tambahHistori("$peminjam mengembalikan $input");
        print("\n$input berhasil dikembalikan oleh $peminjam.");
      } else {
        print("\n$input sedang dipinjam oleh ${buku.peminjam}.");
      }
    } else {
      print("\nBuku tidak ditemukan.");
    }
  }

  print("\nHistori Peminjaman:");
  historiPeminjaman.tampilkanHistori();

  simpanStatusPeminjamanBuku(perpustakaan);
}

void muatStatusPeminjamanBuku(Perpustakaan perpustakaan) {
  try {
    File csvFile = File('status_peminjaman.csv');
    if (csvFile.existsSync()) {
      List<String> lines = csvFile.readAsLinesSync();
      for (int i = 1; i < lines.length; i++) {
        List<String> values = lines[i].split(',');
        if (values.length == 3) {
          String judulBuku = values[0].trim();
          bool dipinjam = values[1].trim().toLowerCase() == 'true';
          String peminjam = values[2].trim();
          perpustakaan.tambahBuku(judulBuku, dipinjam: dipinjam, peminjam: peminjam);
        }
      }
    }
  } catch (e) {
    print('Error saat memuat status peminjaman buku: $e');
  }
}

void simpanStatusPeminjamanBuku(Perpustakaan perpustakaan) {
  try {
    File csvFile = File('status_peminjaman.csv');
    csvFile.writeAsStringSync('Buku,Dipinjam,Peminjam\n');

    Buku? bukuSaatIni = perpustakaan.bukuPertama;
    while (bukuSaatIni != null) {
      csvFile.writeAsStringSync(
          '${bukuSaatIni.judul},${bukuSaatIni.dipinjam ? 'true' : 'false'},${bukuSaatIni.peminjam}\n',
          mode: FileMode.append);
      bukuSaatIni = bukuSaatIni.bukuBerikutnya;
    }

    print("\nStatus peminjaman buku telah disimpan ke status_peminjaman.csv");
  } catch (e) {
    print('Error saat menyimpan status peminjaman buku: $e');
  }
}

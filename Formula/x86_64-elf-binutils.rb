class X8664ElfBinutils < Formula
  desc "GNU binary tools for x86_64 ELF"
  homepage "https://www.gnu.org/software/binutils/binutils.html"
  url "https://ftp.gnu.org/gnu/binutils/binutils-2.35.1.tar.xz"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-2.35.1.tar.xz"
  sha256 "3ced91db9bf01182b7e420eab68039f2083aed0a214c0424e257eae3ddee8607"
  version "2.35.1"

  def install
    mkdir 'build' do
      system "../configure", "--target=x86_64-elf",
                             "--disable-debug",
                             "--disable-dependency-tracking",
                             "--enable-deterministic-archives",
                             "--prefix=#{prefix}",
                             "--infodir=#{info}",
                             "--mandir=#{man}",
                             "--disable-werror",
                             "--enable-interwork",
                             "--enable-multilib",
                             "--enable-64-bit-bfd"
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test-s.s").write <<~EOS
      .section .data
      .section .text
      .globl _start
      _start:
          movl $1, %eax
          movl $4, %ebx
          int $0x80
    EOS
    system "#{bin}/x86_64-elf-as", "--64", "-o", "test-s.o", "test-s.s"
    assert_match "file format elf64-x86-64",
      shell_output("#{bin}/x86_64-elf-objdump -a test-s.o")
  end
end

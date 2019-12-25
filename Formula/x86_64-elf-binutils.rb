class X8664ElfBinutils < Formula
  desc "GNU binary tools for x86_64 ELF"
  homepage "https://www.gnu.org/software/binutils/binutils.html"
  url "https://ftp.gnu.org/gnu/binutils/binutils-2.33.1.tar.xz"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-2.33.1.tar.xz"
  version "2.33.1"
  sha256 "ab66fc2d1c3ec0359b8e08843c9f33b63e8707efdff5e4cc5c200eae24722cbf"

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
    assert_match "Usage:", shell_output("#{bin}/strings #{bin}/strings")
  end
end

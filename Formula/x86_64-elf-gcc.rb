class X8664ElfGcc < Formula
  desc "GNU compiler collection for x86_64 ELF"
  homepage "https://gcc.gnu.org/"
  url "https://ftp.gnu.org/gnu/gcc/gcc-9.2.0/gcc-9.2.0.tar.xz"
  mirror "https://ftpmirror.gnu.org/gcc/gcc-9.2.0/gcc-9.2.0.tar.xz"
  version "9.2.0"
  sha256 "ea6ef08f121239da5695f76c9b33637a118dcf63e24164422231917fa61fb206"

  depends_on "gmp"
  depends_on "isl"
  depends_on "libmpc"
  depends_on "mpfr"
  depends_on "x86_64-elf-binutils"

  option "with-libgcc-mcmodel-large", "Compile libgcc with mcmodel=large"

  # GCC bootstraps itself, so it is OK to have an incompatible C++ stdlib
  cxxstdlib_check :skip

  # Fix system headers for Catalina SDK
  # (otherwise __OSX_AVAILABLE_STARTING ends up undefined)
  if DevelopmentTools.clang_build_version >= 1100
    patch do
      url "https://raw.githubusercontent.com/Homebrew/formula-patches/b8b8e65e/gcc/9.2.0-catalina.patch"
      sha256 "0b8d14a7f3c6a2f0d2498526e86e088926671b5da50a554ffa6b7f73ac4f132b"
    end
  end

  def install
    binutils = Formula["x86_64-elf-binutils"]
    languages = %w[c c++]

    ENV['PATH'] += ":#{binutils.prefix/"bin"}"

    mkdir "build" do
      system "../configure", "--target=x86_64-elf",
                             "--prefix=#{prefix}",
                             "--enable-languages=#{languages.join(",")}",
                             "--disable-nls",
                             "--disable-werror",
                             "--without-headers",
                             "--with-gnu-as",
                             "--with-gnu-ld",
                             "--with-ld=#{binutils.opt_bin/"x86_64-elf-ld"}",
                             "--with-as=#{binutils.opt_bin/"x86_64-elf-as"}",
                             "--with-gmp=#{Formula["gmp"].opt_prefix}",
                             "--with-mpfr=#{Formula["mpfr"].opt_prefix}",
                             "--with-mpc=#{Formula["libmpc"].opt_prefix}",
                             "--with-isl=#{Formula["isl"].opt_prefix}"

      ENV.deparallelize
      system "make", "all-gcc"
      if build.with? "libgcc-mcmodel-large"
        system "make", "all-target-libgcc", "CFLAGS_FOR_TARGET=-g -O2 -mcmodel=large -mno-red-zone"
      else
        system "make", "all-target-libgcc"
      end
      FileUtils.ln_sf binutils.prefix/"x86_64-elf", prefix/"x86_64-elf"
      system "make", "install-gcc"
      system "make", "install-target-libgcc"
    end

    # info and man7 files conflict with native gcc
    info.rmtree
    man7.rmtree
  end

  test do
    (testpath/"hello-c.c").write <<~EOS
      #include <stdio.h>
      int main()
      {
        puts("Hello, world!");
        return 0;
      }
    EOS
    system "#{bin}/gcc-#{version_suffix}", "-o", "hello-c", "hello-c.c"

    (testpath/"hello-cc.cc").write <<~EOS
      #include <iostream>
      int main()
      {
        std::cout << "Hello, world!" << std::endl;
        return 0;
      }
    EOS
    system "#{bin}/g++-#{version_suffix}", "-o", "hello-cc", "hello-cc.cc"
  end
end

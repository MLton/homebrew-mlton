# Installs the binary build of MLton.
# Since MLton is written in ML, building from source
# would require an existing ML compiler/interpreter for bootstrapping.

class StandardHomebrewLocation < Requirement
  satisfy HOMEBREW_PREFIX.to_s == "/usr/local"

  def message; <<-EOS.undent
    mlton won't work outside of /usr/local

    Because this uses pre-compiled binaries, it will not work if
    Homebrew is installed somewhere other than /usr/local; mlton
    will be unable to find GMP.
    EOS
  end
end

class Mlton20130715Binary < Formula
  desc "Whole-program, optimizing compiler for Standard ML"
  homepage "http://mlton.org"
  url "https://downloads.sourceforge.net/project/mlton/mlton/20130715/mlton-20130715-2.amd64-darwin.gmp-static.tgz"
  sha256 "16a6d4e300f45f4af094692cf8033390e4634fa4c072caf6e9c288234100ad22"

  # We download and install the version of MLton which is statically
  # linked to libgmp, but all generated executables will require gmp
  # anyway, hence the dependency
  depends_on StandardHomebrewLocation
  depends_on "gmp"

  def install
    cd "local" do
      mv "man", "share"
      prefix.install Dir["*"]
    end
  end

  test do
    (testpath/"hello.sml").write <<-'EOS'.undent
      val () = print "Hello, world!\n"
    EOS
    system "#{bin}/mlton", "hello.sml"
    system "./hello"
  end
end

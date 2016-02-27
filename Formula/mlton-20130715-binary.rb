# MLton is a self-hosting compiler for Standard ML.
# This formula simply installs the upstream binary release.

class Mlton20130715Binary < Formula
  desc "Whole-program, optimizing compiler for Standard ML"
  homepage "http://mlton.org"
  url "https://downloads.sourceforge.net/project/mlton/mlton/20130715/mlton-20130715-3.amd64-darwin.gmp-static.tgz"
  version "20130715"
  sha256 "7e865cd3d1e48ade3de9b7532a31e94af050ee45f38a2bc87b7b2c45ab91e8e1"

  depends_on "gmp"

  def install
    args = %W[
      WITH_GMP=#{Formula["gmp"].opt_prefix}
      PREFIX=#{prefix}
      MAN_PREFIX_EXTRA=/share
    ]
    system "make", *(args.clone.push "install")
  end

  test do
    (testpath/"hello.sml").write <<-'EOS'.undent
      val () = print "Hello, Homebrew!\n"
    EOS
    system "#{bin}/mlton", "hello.sml"
    assert_equal "Hello, Homebrew!\n", `./hello`
  end
end

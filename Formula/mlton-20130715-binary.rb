# MLton is a self-hosting compiler for Standard ML.
# This formula simply installs the upstream binary release.

class Mlton20130715Binary < Formula
  desc "Whole-program, optimizing compiler for Standard ML"
  homepage "http://mlton.org"
  url "https://downloads.sourceforge.net/project/mlton/mlton/20130715/mlton-20130715-3.amd64-darwin.gmp-static.tgz"
  version "20130715"
  sha256 "cd62202aad4660069e760fc99ecd18f5325bf92b31a3ee2687e438051d189865"

  depends_on "gmp"

  def install
    args = %W[
      WITH_GMP=#{Formula["gmp"].opt_prefix}
      PREFIX=#{prefix}
      MAN_PREFIX_EXTRA=/share
    ]
    system "make", *args, "install"
  end

  test do
    (testpath/"hello.sml").write <<-'EOS'.undent
      val () = print "Hello, Homebrew!\n"
    EOS
    system "#{bin}/mlton", "hello.sml"
    assert_equal "Hello, Homebrew!\n", `./hello`
  end
end

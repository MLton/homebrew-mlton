# MLton is a self-hosting compiler for Standard ML.
# In order to build from source, this formula uses the corresponding
# upstream binary release to bootstrap.

class Mlton20130715Source < Formula
  desc "Whole-program, optimizing compiler for Standard ML"
  homepage "http://mlton.org"
  url "https://downloads.sourceforge.net/project/mlton/mlton/20130715/mlton-20130715.src.tgz"
  version "20130715"
  sha256 "215857ad11d44f8d94c27f75e74017aa44b2c9703304bcec9e38c20433143d6c"

  depends_on "gmp"

  # The corresponding upstream binary release used to bootstrap.
  resource "bootstrap" do
    url "https://downloads.sourceforge.net/project/mlton/mlton/20130715/mlton-20130715-3.amd64-darwin.gmp-static.tgz"
    sha256 "cd62202aad4660069e760fc99ecd18f5325bf92b31a3ee2687e438051d189865"
  end

  # Support configuring GMP location (https://github.com/MLton/mlton/issues/134)
  # upstream merge commit:
  patch do
    url "https://github.com/MatthewFluet/mlton/commit/6e79342cdcf2e15193d95fcd3a46d164b783aed4.diff"
    sha256 "2d44891eaf3fdecd3b0f6de2bdece463c71c425100fbac2d00196ad159e5c707"
  end

  def install
    # Install the corresponding upstream binary release to 'bootstrap'.
    bootstrap = buildpath/"bootstrap"
    resource("bootstrap").stage do
      args = %W[
        WITH_GMP=#{Formula["gmp"].opt_prefix}
        PREFIX=#{bootstrap}
        MAN_PREFIX_EXTRA=/share
      ]
      system "make", *args, "install"
    end
    ENV.prepend_path "PATH", bootstrap/"bin"

    # Support parallel builds (https://github.com/MLton/mlton/issues/132)
    ENV.deparallelize
    args = %W[
      WITH_GMP=#{Formula["gmp"].opt_prefix}
      DESTDIR=
      PREFIX=#{prefix}
      MAN_PREFIX_EXTRA=/share
    ]
    system "make", *args, "all-no-docs"
    system "make", *args, "install-no-docs"
  end

  test do
    (testpath/"hello.sml").write <<-'EOS'.undent
      val () = print "Hello, Homebrew!\n"
    EOS
    system "#{bin}/mlton", "hello.sml"
    assert_equal "Hello, Homebrew!\n", `./hello`
  end
end

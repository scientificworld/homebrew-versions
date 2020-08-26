class Freetds091 < Formula
  desc "Libraries to talk to Microsoft SQL Server & Sybase"
  homepage "http://www.freetds.org/"
  url "ftp://ftp.freetds.org/pub/freetds/stable/freetds-0.91.112.tar.gz"
  sha256 "be4f04ee57328c32e7e7cd7e2e1483e535071cec6101e46b9dd15b857c5078ed"

  bottle do
    sha256 "55c1bb525c855bc3684082ab45cd52bca491f69f3288a7811d321ee15df79693" => :yosemite
    sha256 "959d10ae87e9135979e0e3819b38e0def9195d85fa66daaf96ed40c834dd7cf1" => :mavericks
    sha256 "748d584c119cb5a6e8b6269256c70bf646f9af37f42859014dd7f77902347ff7" => :mountain_lion
  end

  option :universal
  option "with-msdblib", "Enable Microsoft behavior in the DB-Library API where it diverges from Sybase's"
  option "with-sybase-compat", "Enable close compatibility with Sybase's ABI, at the expense of other features"
  option "with-odbc-wide", "Enable odbc wide, prevent unicode - MemoryError's"
  option "with-krb5", "Enable Kerberos support"
  option "without-openssl", "Build without OpenSSL support (default is to use brewed OpenSSL)"

  depends_on "pkg-config" => :build
  depends_on "unixodbc" => :optional
  depends_on "openssl" => :recommended

  conflicts_with "freetds", :because => "Differing version of same formula"

  def install
    system "autoreconf", "-i" if build.head?

    args = %W[
      --prefix=#{prefix}
      --with-tdsver=7.1
      --mandir=#{man}
    ]

    if build.with? "openssl"
      args << "--with-openssl=#{Formula["openssl"].opt_prefix}"
    end

    if build.with? "unixodbc"
      args << "--with-unixodbc=#{Formula["unixodbc"].opt_prefix}"
    end

    # Translate formula's "--with" options to configuration script's "--enable"
    # options
    %w[msdblib sybase-compat odbc-wide krb5].each do |option|
      if build.with? option
        args << "--enable-#{option}"
      end
    end

    ENV.universal_binary if build.universal?
    system "./configure", *args
    system "make"
    ENV.deparallelize # Or fails to install on multi-core machines
    system "make", "install"
  end

  test do
    system "#{bin}/tsql", "-C"
  end
end

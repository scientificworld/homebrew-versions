class PerconaServer55 < Formula
  desc "Drop-in MySQL replacement"
  homepage "http://www.percona.com"
  url "http://www.percona.com/downloads/Percona-Server-5.5/Percona-Server-5.5.41-37.0/source/tarball/percona-server-5.5.41-37.0.tar.gz"
  version "5.5.41-37.0"
  sha256 "4de65ccbdd6c266f18339c2ea5427a15d90a8ce1ce1c7574aa2e72f685a10833"

  bottle do
    sha256 "a9eff85dcbcbffa7c6fa5a8fd0f9a4d7d9808938feed226772aabb83c0b26ec6" => :sierra
    sha256 "436238fe2ffe73a09c5452a4d8997d390e9592d6936a4d8f2a1525cc5d03f468" => :el_capitan
    sha256 "cf933e833ac7235bdabfe87f1e29f72f85e489f3c13c80ce94854147ff6eaccc" => :yosemite
  end

  revision 1

  option :universal
  option "with-tests", "Build with unit tests"
  option "with-embedded", "Build the embedded server"
  option "with-libedit", "Compile with editline wrapper instead of readline"
  option "with-local-infile", "Build with local infile loading support"

  deprecated_option "enable-local-infile" => "with-local-infile"

  depends_on "cmake" => :build
  depends_on "readline"
  depends_on "pidof"
  depends_on "openssl"

  conflicts_with "mysql",
    :because => "percona-server55 and mysql install the same binaries."

  conflicts_with "mariadb",
    :because => "percona-server55 and mariadb install the same binaries."

  conflicts_with "mysql-cluster",
    :because => "percona-server55 and mysql-cluster install the same binaries."

  conflicts_with "percona-server",
    :because => "percona-server55 and percona-server install the same binaries."

  # Where the database files should be located. Existing installs have them
  # under var/percona, but going forward they will be under var/msyql to be
  # shared with the mysql and mariadb formulae.
  def destination
    @destination ||= (var/"percona").directory? ? "percona" : "mysql"
  end

  def install
    # Make sure that data directory exists
    (var/destination).mkpath

    args = [
      ".",
      "-DCMAKE_INSTALL_PREFIX=#{prefix}",
      "-DMYSQL_DATADIR=#{var}/#{destination}",
      "-DINSTALL_MANDIR=#{man}",
      "-DINSTALL_DOCDIR=#{doc}",
      "-DINSTALL_INFODIR=#{info}",
      # CMake prepends prefix, so use share.basename
      "-DINSTALL_MYSQLSHAREDIR=#{share.basename}/mysql",
      "-DWITH_SSL=yes",
      "-DDEFAULT_CHARSET=utf8",
      "-DDEFAULT_COLLATION=utf8_general_ci",
      "-DSYSCONFDIR=#{etc}",
      "-DCMAKE_BUILD_TYPE=RelWithDebInfo",
      # PAM plugin is Linux-only at the moment
      "-DWITHOUT_AUTH_PAM=1",
      "-DWITHOUT_AUTH_PAM_COMPAT=1",
      "-DWITHOUT_DIALOG=1",
    ]

    # To enable unit testing at build, we need to download the unit testing suite
    if build.with? "tests"
      args << "-DENABLE_DOWNLOADS=ON"
    else
      args << "-DWITH_UNIT_TESTS=OFF"
    end

    # Build the embedded server
    args << "-DWITH_EMBEDDED_SERVER=ON" if build.with? "embedded"

    # Compile with readline unless libedit is explicitly chosen
    args << "-DWITH_READLINE=yes" if build.without? "libedit"

    # Make universal for binding to universal applications
    if build.universal?
      ENV.universal_binary
      args << "-DCMAKE_OSX_ARCHITECTURES=#{Hardware::CPU.universal_archs.as_cmake_arch_flags}"
    end

    # Build with local infile loading support
    args << "-DENABLED_LOCAL_INFILE=1" if build.include? "enable-local-infile"

    system "cmake", *args
    system "make"
    system "make", "install"

    # Don't create databases inside of the prefix!
    # See: https://github.com/mxcl/homebrew/issues/4975
    rm_rf prefix+"data"

    # Link the setup script into bin
    ln_s prefix+"scripts/mysql_install_db", bin+"mysql_install_db"

    # Fix up the control script and link into bin
    inreplace "#{prefix}/support-files/mysql.server",
      /^(PATH=".*)(")/, "\\1:#{HOMEBREW_PREFIX}/bin\\2"

    ln_s "#{prefix}/support-files/mysql.server", bin

    # Move mysqlaccess to libexec
    libexec.mkpath
    mv "#{bin}/mysqlaccess", libexec
    mv "#{bin}/mysqlaccess.conf", libexec
  end

  def caveats; <<-EOS.undent
    Set up databases to run AS YOUR USER ACCOUNT with:
        unset TMPDIR
        mysql_install_db --verbose --user=`whoami` --basedir="$(brew --prefix percona-server55)" --datadir=#{var}/#{destination} --tmpdir=/tmp

    To set up base tables in another folder, or use a different user to run
    mysqld, view the help for mysqld_install_db:
        mysql_install_db --help

    and view the MySQL documentation:
      * http://dev.mysql.com/doc/refman/5.5/en/mysql-install-db.html
      * http://dev.mysql.com/doc/refman/5.5/en/default-privileges.html

    To run as, for instance, user "mysql", you may need to `sudo`:
        sudo mysql_install_db ...options...

    A "/etc/my.cnf" from another install may interfere with a Homebrew-built
    server starting up correctly.

    To connect:
        mysql -uroot
    EOS
  end

  plist_options :manual => "mysql.server start"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>Program</key>
      <string>#{opt_prefix}/bin/mysqld_safe</string>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{var}</string>
    </dict>
    </plist>
    EOS
  end
end

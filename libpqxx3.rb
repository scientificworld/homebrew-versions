class Libpqxx3 < Formula
  desc "C++ connector for PostgreSQL"
  homepage "http://pqxx.org/development/libpqxx/"
  url "http://pqxx.org/download/software/libpqxx/libpqxx-3.1.1.tar.gz"
  sha256 "ce443c7c515623b4a68de5f0657460344b6b6320982d8f8efc657c3746e1ee90"

  bottle do
    cellar :any
    sha256 "5ee9ebd4b524601f6af244f2bea9b1a205db569ec8d3e895b8c93aa6e565280d" => :yosemite
    sha256 "f568487e046b03b022dc87152ca74ad4b6c1f6a8048f670437d4983d2cd967bd" => :mavericks
    sha256 "b4a1fa555cc0d804eac4a45b101dda02bbef3744efa52de8a3d63711fac4c34e" => :mountain_lion
  end

  depends_on "pkg-config" => :build
  depends_on :postgresql

  # Patch 1 borrowed from MacPorts. See:
  # https://trac.macports.org/ticket/33671
  #
  # (1) Patched maketemporary to avoid an error message about improper use
  #     of the mktemp command; apparently maketemporary is designed to call
  #     mktemp in various ways, some of which may be improper, as it attempts
  #     to determine how to use it properly; we don't want to see those errors
  #     in the configure phase output.
  # (2) Patched largeobject.hxx per the ticket at the following URL:
  #     http://pqxx.org/development/libpqxx/ticket/252
  patch :DATA

  def install
    ENV.deparallelize

    system "./configure", "--prefix=#{prefix}", "--enable-shared"
    system "make", "install"
  end
end

__END__
diff --git a/tools/maketemporary b/tools/maketemporary
index 242f63b..f9f6661 100755
--- a/tools/maketemporary
+++ b/tools/maketemporary
@@ -5,7 +5,7 @@
 TMPDIR="${TMPDIR:-/tmp}"
 export TMPDIR

-T="`mktemp`"
+T="`mktemp 2>/dev/null`"
 if test -z "$T" ; then
	      T="`mktemp -t pqxx.XXXXXX`"
 fi
diff --git a/include/pqxx/largeobject.hxx b/include/pqxx/largeobject.hxx
index 73d16c0..b2caeed 100644
--- a/include/pqxx/largeobject.hxx
+++ b/include/pqxx/largeobject.hxx
@@ -396,7 +396,7 @@ public:
			openmode mode = PGSTD::ios::in | PGSTD::ios::out,
			size_type BufSize=512) :			//[t48]
     m_BufSize(BufSize),
-    m_Obj(T, O),
+    m_Obj(T, O, mode),
     m_G(0),
     m_P(0)
	{ initialize(mode); }
@@ -406,7 +406,7 @@ public:
			openmode mode = PGSTD::ios::in | PGSTD::ios::out,
			size_type BufSize=512) :			//[t48]
     m_BufSize(BufSize),
-    m_Obj(T, O),
+    m_Obj(T, O, mode),
     m_G(0),
     m_P(0)
	{ initialize(mode); }

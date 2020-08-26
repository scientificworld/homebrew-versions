class OpenMpi16 < Formula
  homepage "http://www.open-mpi.org/"
  url "http://www.open-mpi.org/software/ompi/v1.6/downloads/openmpi-1.6.5.tar.bz2"
  sha256 "fe37bab89b5ef234e0ac82dc798282c2ab08900bf564a1ec27239d3f1ad1fc85"

  bottle do
    sha256 "62ba62c636ccf8ecedd44429b4b5289af8580c499e85d2cc54f0d3015fd7b318" => :yosemite
    sha256 "7146c0325758769fd48cba0565764c5c287eb53de8d47428e000546f51858bcb" => :mavericks
    sha256 "3d2986df69b5f759c56956ee0c94a93447ef69ed5e2bc3b42ffada4d8eacdca1" => :mountain_lion
  end

  option "without-fortran", "Do not build the Fortran bindings"
  option "with-mpi-thread-multiple", "Enable MPI_THREAD_MULTIPLE"

  deprecated_option "disable-fortran" => "without-fortran"
  deprecated_option "enable-mpi-thread-multiple" => "with-mpi-thread-multiple"

  keg_only "Conflicts with open-mpi in Homebrew/homebrew"

  depends_on :fortran => :recommended

  # Fixes error in tests, which makes them fail on clang.
  # Upstream ticket: https://svn.open-mpi.org/trac/ompi/ticket/4255
  patch :DATA

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-ipv6
    ]

    args << "--disable-mpi-f77" << "--disable-mpi-f90" if build.without? "fortran"
    args << "--enable-mpi-thread-multiple" if build.with? "mpi-thread-multiple"

    system "./configure", *args
    system "make", "all"
    system "make", "check"
    system "make", "install"

    # If Fortran bindings were built, there will be a stray `.mod` file
    # (Fortran header) in `lib` that needs to be moved to `include`.
    include.install lib/"mpi.mod" if File.exist? "#{lib}/mpi.mod"

    # Not sure why the wrapped script has a jar extension - adamv
    libexec.install bin/"vtsetup.jar"
    bin.write_jar_script libexec/"vtsetup.jar", "vtsetup.jar"
  end

  test do
    (testpath/"hello.c").write <<-EOS.undent
      #include <mpi.h>
      #include <stdio.h>

      int main()
      {
        int size, rank, nameLen;
        char name[MPI_MAX_PROCESSOR_NAME];
        MPI_Init(NULL, NULL);
        MPI_Comm_size(MPI_COMM_WORLD, &size);
        MPI_Comm_rank(MPI_COMM_WORLD, &rank);
        MPI_Get_processor_name(name, &nameLen);
        printf("[%d/%d] Hello, world! My name is %s.\\n", rank, size, name);
        MPI_Finalize();
        return 0;
      }
    EOS

    system "#{bin}/mpicc", "hello.c", "-o", "hello"
    system "./hello"
    system "#{bin}/mpirun", "-np", "4", "./hello"
  end
end

__END__
diff --git a/test/datatype/ddt_lib.c b/test/datatype/ddt_lib.c
index 015419d..c349384 100644
--- a/test/datatype/ddt_lib.c
+++ b/test/datatype/ddt_lib.c
@@ -209,7 +209,7 @@ int mpich_typeub2( void )

 int mpich_typeub3( void )
 {
-   int blocklen[2], err = 0, idisp[3];
+   int blocklen[3], err = 0, idisp[3];
    size_t sz;
    MPI_Aint disp[3], lb, ub, ex;
    ompi_datatype_t *types[3], *dt1, *dt2, *dt3, *dt4, *dt5;
diff --git a/test/datatype/opal_ddt_lib.c b/test/datatype/opal_ddt_lib.c
index 4491dcc..b58136d 100644
--- a/test/datatype/opal_ddt_lib.c
+++ b/test/datatype/opal_ddt_lib.c
@@ -761,7 +761,7 @@ int mpich_typeub2( void )

 int mpich_typeub3( void )
 {
-   int blocklen[2], err = 0, idisp[3];
+   int blocklen[3], err = 0, idisp[3];
    size_t sz;
    OPAL_PTRDIFF_TYPE disp[3], lb, ub, ex;
    opal_datatype_t *types[3], *dt1, *dt2, *dt3, *dt4, *dt5;

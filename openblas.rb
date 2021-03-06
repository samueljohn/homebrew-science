require 'formula'

# Avoid openblas downloading the LAPACK on demand.
# We want openblas to build LAPACK because it knows how to patch LAPACK,
# but we want to download, cache and checksum that!
class OpenblasLapack < Formula
  url 'http://www.netlib.org/lapack/lapack-3.4.2.tgz'
  sha1 '93a6e4e6639aaf00571d53a580ddc415416e868b'
end

class Openblas < Formula
  homepage 'http://xianyi.github.com/OpenBLAS/'
  # Maintainers, remember to update the LAPACK url in OpenblasLapack above.
  # See the "LAPACK_URL" in the openblas Makefile for the right version.
  url 'http://github.com/xianyi/OpenBLAS/zipball/v0.2.4'
  sha1 'd3c17f7723a0a23022d8de1efcfcf4ace5a7d595'
  head "https://github.com/xianyi/OpenBLAS.git"

  # OS X provides the Accelerate.framework, which is a BLAS/LAPACK impl.
  keg_only :provided_by_osx

  # Currently superenv works only with setting FC to gfortran-4.7 from
  # homebrew/dupes/gcc (`brew install gcc --enable-fortran`).
  # It's (probably) a superenv-bug that openblas does currently not work with
  # gfortran from `brew install gfortran`, therefore:
  env :std unless ENV['FC']

  def install
    ENV.fortran

    lapack = OpenblasLapack.new
    lapack.brew{}  # download and checksum
    ohai "Using LAPACK: #{lapack.cached_download}"

    inreplace 'Makefile',
              'LAPACK_URL=http://www.netlib.org/lapack/lapack-3.4.2.tgz',
              "LAPACK_URL=file://#{lapack.cached_download}"

    # Must call in two steps
    system "make", "FC=#{ENV['FC']}"
    system "make", "PREFIX=#{prefix}", "install"
  end
end

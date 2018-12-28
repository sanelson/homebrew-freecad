class Opencamlib < Formula
  desc "Computer Aided Manufacturing libraries"
  homepage "http://www.anderswallin.net/CAM/"
  url "https://github.com/aewallin/opencamlib.git",
      :revision => "f31b0a672c6850e6c830a0e314d9a75606359453"
  version "0.0.1" # TODO: Specify a real version here - note usage below
  head "https://github.com/aewallin/opencamlib.git", :using => :git

  bottle do
    root_url "https://homebrew.bintray.com/bottles-freecad"
    cellar :any
    sha256 "d44870c9f77c902a238b5c4832fcb1c96957b09630c5cd59f96bfa30d72d7d1a" => :sierra
  end

  option "with-openmp", "Build with support for OpenMP parallel processing"

  depends_on "cmake" => :build
  depends_on "llvm" => :build if build.with?("openmp")
  depends_on "boost-python@1.59" # TODO: Fails to locate files with homebrew boost 1.68, pin to 1.59
  depends_on "python@2" => :recommended

  # Path https://github.com/aewallin/opencamlib/pull/36 until it is merged upstream
  patch :DATA

  def install
    if build.with? "openmp"
      llvm_lib = Formula["llvm"].lib
      llvm_inc = "#{llvm_lib}/clang/#{Formula["llvm"].version}" << "/include"
    end

    mkdir "build" do
      cmake_args = std_cmake_args
      if build.with? "openmp"
        cmake_args << "-DCMAKE_C_COMPILER=#{Formula["llvm"].bin}/clang"
        cmake_args << "-DCMAKE_CXX_COMPILER=#{Formula["llvm"].bin}/clang++"
        cmake_args << "-DCMAKE_MODULE_LINKER_FLAGS=-undefined dynamic_lookup -L#{llvm_lib} -Wl,-rpath,#{llvm_lib}"
        cmake_args << "-DCMAKE_C_FLAGS=-I#{llvm_inc}"
        cmake_args << "-DCMAKE_CXX_FLAGS=-I#{llvm_inc} -std=c++11"
        cmake_args << "-DMY_VERSION=#{version}"
      else
        cmake_args << "-DUSE_OPENMP=0"
        cmake_args << "-DCMAKE_MODULE_LINKER_FLAGS=-undefined dynamic_lookup"
      end

      cmake_args << "-DBOOST_ROOT=#{Formula["boost@1.59"].prefix}"
      if build.with? "python@2"
        cmake_args << "-DPYTHON_EXECUTABLE=#{Formula["python@2"].bin}/python2"
      else
        cmake_args << "-DBUILD_PY_LIB=0"
      end

      system "cmake", *cmake_args, ".."
      system "make", "-j#{ENV.make_jobs}", "install"
    end
  end
end
__END__
diff --git a/src/CMakeLists.txt b/src/CMakeLists.txt
index f262c37..66f7647 100644
--- a/src/CMakeLists.txt
+++ b/src/CMakeLists.txt
@@ -169,9 +169,9 @@ ELSE(EXISTS ${OpenCamLib_SOURCE_DIR}/version_string.hpp)
   include_directories(${CMAKE_CURRENT_BINARY_DIR})
   include(version_string.cmake)
   # now parse the git commit id:
-  STRING(REGEX REPLACE "([0-9][0-9]).*" "\\1" GIT_MAJOR_VERSION "${GIT_COMMIT_ID}" )
-  STRING(REGEX REPLACE "[0-9][0-9].([0-9][0-9])-.*" "\\1" GIT_MINOR_VERSION "${GIT_COMMIT_ID}" )
-  STRING(REGEX REPLACE "[0-9][0-9].[0-9][0-9]-(.*)-.*" "\\1" GIT_PATCH_VERSION "${GIT_COMMIT_ID}" )
+  STRING(REGEX REPLACE "([0-9]+).*" "\\1" GIT_MAJOR_VERSION "${GIT_COMMIT_ID}" )
+  STRING(REGEX REPLACE "[0-9]+.([0-9]+)-.*" "\\1" GIT_MINOR_VERSION "${GIT_COMMIT_ID}" )
+  STRING(REGEX REPLACE "[0-9]+.[0-9]+-(.*)-.*" "\\1" GIT_PATCH_VERSION "${GIT_COMMIT_ID}" )
   SET(MY_VERSION "${GIT_MAJOR_VERSION}.${GIT_MINOR_VERSION}.${GIT_PATCH_VERSION}" CACHE STRING "name")
   SET(version_string ${CMAKE_CURRENT_BINARY_DIR}/version_string.hpp)
 ENDIF(EXISTS ${OpenCamLib_SOURCE_DIR}/version_string.hpp)
@@ -319,7 +319,11 @@ if (BUILD_PY_LIB)
     )
 
   message(STATUS "linking python binary ocl.so with boost: " ${Boost_PYTHON_LIBRARY})
-  target_link_libraries(ocl ocl_common ocl_dropcutter ocl_cutters  ocl_geo ocl_algo ${Boost_LIBRARIES}  ${PYTHON_LIBRARIES} -lboost_python -lboost_system)
+  if (NOT APPLE)
+    target_link_libraries(ocl ocl_common ocl_dropcutter ocl_cutters  ocl_geo ocl_algo ${Boost_LIBRARIES}  ${PYTHON_LIBRARIES} -lboost_python -lboost_system)
+  else (NOT APPLE)
+    target_link_libraries(ocl ocl_common ocl_dropcutter ocl_cutters  ocl_geo ocl_algo ${Boost_LIBRARIES} -lboost_python -lboost_system)
+  endif (NOT APPLE)
   # 
   # this makes the lib name ocl.so and not libocl.so
   set_target_properties(ocl PROPERTIES PREFIX "") 

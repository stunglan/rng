using PackageCompiler

PackageCompiler.create_sysimage(["Makie","GLMakie","CairoMakie","WGLMakie"],sysimage_path="makie_image.so")
root = @_stasis.root
@_stasis.root = "#{root}/src"
@_stasis.destination = "#{root}/lib"
puts "Compiling to " + @_stasis.destination

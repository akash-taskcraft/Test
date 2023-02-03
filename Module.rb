module Student
	module Info
		def self.information
			puts "Hello world"
		end
	end
end


puts Student::Info.information
# class Test
# 	include Student::Info
# end

# test = Test.new
# test.information

# puts Student::Info.information


# module Manage
# 	module Student
# 		class Info
# 			def information
# 				puts "Hello world"
# 			end
# 		end
# 	end
# end

# puts Manage::Student::Info.new.information


class Demo
	module Test
		def self.a
			puts "Hi fdbdhbfdnsznbaz"
		end
	end
end

puts Demo::Test.a
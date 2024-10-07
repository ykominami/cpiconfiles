h = {"a"=>200, "b"=>300, "c" => 400}

h.each_with_index{ |kv ,index|
	puts "k=#{kv[0]} v=#{kv[1]} index=#{index}"
}

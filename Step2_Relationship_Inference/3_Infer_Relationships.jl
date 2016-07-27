#=
Inferred relationships in Julia

Data: relationships AND opposites

Export as csv with lines terminated by '/r'

Run: julia 3_Infer_Relationships.jl
 
=#

# define the matches dictionary
matches_dict = Dict{ASCIIString,Array{Tuple{ASCIIString, ASCIIString, Int64}}}()

fh = open("patient_relations_w_opposites_clean.csv", "r")
rel_text = readall(fh)

lines = split(rel_text, '\r')

i = 0
for ln in lines
	i += 1
	if i == 1
		continue
	end

	row = split(ln, ',')
	#print(row[1])
	
	if haskey(matches_dict, row[1])
		push!(matches_dict[row[1]], (row[2], row[3], 0))
	else
		matches_dict[row[1]] = [(row[2], row[3], 0)]
	end
end



function contains(test_relationship, test_mrn, pair_to_compare)
	for w in 1:length(pair_to_compare)
		if test_relationship == pair_to_compare[w][1]
			if test_mrn == pair_to_compare[w][2]
				return true 
			end
		end #if
	end
	return false
end


x = deepcopy(matches_dict)
#print(x)
b = 0
while true
	a = 0
	f = 0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
	x2 = x
	b += 1
	#print(b)
	for i in keys(x) ###i is the key of the dictionary (EMPI)
		f += 1
		#print(i)
		#print("\t")
		#print(f)
		#print(" of ")
		#print(length(x))
		#print("\n")
		#print("i is", i)
		#print("\t")
		#print(a)
		#print("\n")
		for j in x[i] ### j are the pairs of relationships associated with the empi i
			#print(j)
			#print("\t")
			#print(haskey(x, j[2]))
			#print("\t")
			if haskey(x, j[2]) #tries to find the empi from the pair as key 
				#print(a)
				#print("\t")
				#print(j[1])
				for z in x[j[2]] #z are the relationships from the empi that was found as a key
					#print(z)
					#print("\t")
					#print(j[1])
					#print("\t")

					
					if z[2] == i
						# we won't infer relationships from the individual to themselves
						continue
					end
					
					
					if j[1] == "Parent"
						if z[1] == "Sibling"
							if contains("Aunt/Uncle", z[2], x[i]) == false
								#print(i, "\t", a)
								push!(x2[i], ("Aunt/Uncle", z[2], b))
								a += 1
								#print(a)
							end
						elseif z[1] == "Aunt/Uncle"
							if contains("Grandaunt/Granduncle", z[2], x[i]) == false
								push!(x2[i], ("Grandaunt/Granduncle", z[2], b))
								a += 1
							end	
						elseif z[1] == "Child"
							if contains("Sibling", z[2], x[i]) == false
								push!(x2[i], ("Sibling", z[2], b))
								a += 1
							end
						elseif z[1] == "Grandchild"
							if contains("Child/Nephew/Niece", z[2], x[i]) == false
								push!(x2[i], ("Child/Nephew/Niece", z[2], b))
								a += 1
							end
						elseif z[1] == "Grandparent"
							if contains("Great-grandparent", z[2], x[i]) == false
								push!(x2[i], ("Great-grandparent", z[2], b))
								a += 1
							end
						elseif z[1] == "Nephew/Niece"
							if contains("Cousin", z[2], x[i]) == false
								push!(x2[i], ("Cousin", z[2], b))
								a += 1
							end
						elseif z[1] == "Parent"
							if contains("Grandparent", z[2], x[i]) == false
								push!(x2[i], ("Grandparent", z[2], b))
								a += 1
								#print("Parent/Parent", a)
							end
						end
					end
				
					if j[1] == "Child"
						if z[1] == "Aunt/Uncle"
							if contains("Sibling/Sibling-in-law", z[2], x[i]) == false
								push!(x2[i], ("Sibling/Sibling-in-law", z[2], b))
								a += 1
							end
						elseif z[1] == "Child"
							if contains("Grandchild", z[2], x[i]) == false
								push!(x2[i], ("Grandchild", z[2], b))
								a += 1
							end	
						elseif z[1] == "Grandchild"
							if contains("Great-grandchild", z[2], x[i]) == false
								push!(x2[i], ("Great-grandchild", z[2], b))
								a += 1
							end
						elseif z[1] == "Grandparent"
							if contains("Parent/Parent-in-law", z[2], x[i]) == false
								push!(x2[i], ("Parent/Parent-in-law", z[2], b))
								a += 1
							end
						elseif z[1] == "Nephew/Niece"
							if contains("Grandchild/Grandchild-in-law", z[2], x[i]) == false
								push!(x2[i], ("Grandchild/Grandchild-in-law", z[2], b))
								a += 1
							end
						elseif z[1] == "Parent"
							if contains("Spouse", z[2], x[i]) == false
								push!(x2[i], ("Spouse", z[2], b))
								a += 1
							end
						elseif z[1] == "Sibling"
							if contains("Child", z[2], x[i]) == false
								push!(x2[i], ("Child", z[2], b))
								a += 1
							end
						end
					end
						
					if j[1] == "Sibling"
						if z[1] == "Aunt/Uncle"
							if contains("Aunt/Uncle", z[2], x[i]) == false
								push!(x2[i], ("Aunt/Uncle", z[2], b))
								a += 1
							end
						elseif z[1] == "Child"
							if contains("Nephew/Niece", z[2], x[i]) == false
								push!(x2[i], ("Nephew/Niece", z[2], b))
								a += 1
							end	
						elseif z[1] == "Grandchild"
							if contains("Grandnephew/Grandniece", z[2], x[i]) == false
								push!(x2[i], ("Grandnephew/Grandniece", z[2], b))
								a += 1
							end
						elseif z[1] == "Grandparent"
							if contains("Grandparent", z[2], x[i]) == false
								push!(x2[i], ("Grandparent", z[2], b))
								a += 1
							end
						elseif z[1] == "Nephew/Niece"
							if contains("Child/Nephew/Niece", z[2], x[i]) == false
								push!(x2[i], ("Child/Nephew/Niece", z[2], b))
								a += 1
							end
						elseif z[1] == "Parent"
							if contains("Parent", z[2], x[i]) == false
								push!(x2[i], ("Parent", z[2], b))
								a += 1
								#print("Sibling/Parent:", a)
							end
						elseif z[1] == "Sibling"
							if contains("Sibling", z[2], x[i]) == false
								push!(x2[i], ("Sibling", z[2], b))
								a += 1
							end
						end
					end
							
					if j[1] == "Aunt/Uncle"
						if z[1] == "Aunt/Uncle"
							if contains("Grandaunt/Granduncle/Grandaunt-in-law/Granduncle-in-law", z[2], x[i]) == false
								push!(x2[i], ("Grandaunt/Granduncle/Grandaunt-in-law/Granduncle-in-law", z[2], b))
								a += 1
							end
						elseif z[1] == "Child"
							if contains("Cousin", z[2], x[i]) == false
								push!(x2[i], ("Cousin", z[2], b))
								a += 1
							end	
						elseif z[1] == "Grandchild"
							if contains("First cousin once removed", z[2], x[i]) == false
								push!(x2[i], ("First cousin once removed", z[2], b))
								a += 1
							end
						elseif z[1] == "Grandparent"
							if contains("Great-grandparent/Great-grandparent-in-law", z[2], x[i]) == false
								push!(x2[i], ("Great-grandparent/Great-grandparent-in-law", z[2], b))
								a += 1
							end
						elseif z[1] == "Nephew/Niece"
							if contains("Sibling/Cousin", z[2], x[i]) == false
								push!(x2[i], ("Sibling/Cousin", z[2], b))
								a += 1
							end
						elseif z[1] == "Parent"
							if contains("Grandparent/Grandparent-in-law", z[2], x[i]) == false
								push!(x2[i], ("Grandparent/Grandparent-in-law", z[2], b))
								a += 1
							end
						elseif z[1] == "Sibling"
							if contains("Parent/Aunt/Uncle", z[2], x[i]) == false
								push!(x2[i], ("Parent/Aunt/Uncle", z[2], b))
								a += 1
							end
						end
					end
								
					if j[1] == "Grandchild"
						if z[1] == "Aunt/Uncle"
							if contains("Child/Child-in-law", z[2], x[i]) == false
								push!(x2[i], ("Child/Child-in-law", z[2], b))
								a += 1
							end
						elseif z[1] == "Child"
							if contains("Great-grandchild", z[2], x[i]) == false
								push!(x2[i], ("Great-grandchild", z[2], b))
								a += 1
							end	
						elseif z[1] == "Grandchild"
							if contains("Great-great-grandchild", z[2], x[i]) == false
								push!(x2[i], ("Great-great-grandchild", z[2], b))
								a += 1
							end
						elseif z[1] == "Grandparent"
							if contains("Spouse", z[2], x[i]) == false
								push!(x2[i], ("Spouse", z[2], b))
								a += 1
							end
						elseif z[1] == "Nephew/Niece"
							if contains("Great-grandchild/Great-grandchild-in-law", z[2], x[i]) == false
								push!(x2[i], ("Great-grandchild/Great-grandchild-in-law", z[2], b))
								a += 1
							end
						elseif z[1] == "Parent"
							if contains("Child/Child-in-law", z[2], x[i]) == false
								push!(x2[i], ("Child/Child-in-law", z[2], b))
								a += 1
							end
						elseif z[1] == "Sibling"
							if contains("Grandchild", z[2], x[i]) == false
								push!(x2[i], ("Grandchild", z[2], b))
								a += 1
							end
						end
					end
									
					if j[1] == "Grandparent"
						if z[1] == "Aunt/Uncle"
							if contains("Great-grandaunt/Great-granduncle", z[2], x[i]) == false
								push!(x2[i], ("Great-grandaunt/Great-granduncle", z[2], b))
								a += 1
							end
						elseif z[1] == "Child"
							if contains("Parent/Aunt/Uncle", z[2], x[i]) == false
								push!(x2[i], ("Parent/Aunt/Uncle", z[2], b))
								a += 1
							end	
						elseif z[1] == "Grandchild"
							if contains("Sibling/Cousin", z[2], x[i]) == false
								push!(x2[i], ("Sibling/Cousin", z[2], b))
								a += 1
							end
						elseif z[1] == "Grandparent"
							if contains("Great-great-grandparent", z[2], x[i]) == false
								push!(x2[i], ("Great-great-grandparent", z[2], b))
								a += 1
							end
						elseif z[1] == "Nephew/Niece"
							if contains("First cousin once removed", z[2], x[i]) == false
								push!(x2[i], ("First cousin once removed", z[2], b))
								a += 1
							end
						elseif z[1] == "Parent"
							if contains("Great-grandparent", z[2], x[i]) == false
								push!(x2[i], ("Great-grandparent", z[2], b))
								a += 1
							end
						elseif z[1] == "Sibling"
							if contains("Grandaunt/Granduncle", z[2], x[i]) == false
								push!(x2[i], ("Grandaunt/Granduncle", z[2], b))
								a += 1
							end
						end
					end
					
					
					if j[1] == "Nephew/Niece"
						if z[1] == "Aunt/Uncle"
							if contains("Sibling/Sibling-in-law", z[2], x[i]) == false
								push!(x2[i], ("Sibling/Sibling-in-law", z[2], b))
								a += 1
							end
						elseif z[1] == "Child"
							if contains("Grandnephew/Grandniece", z[2], x[i]) == false
								push!(x2[i], ("Grandnephew/Grandniece", z[2], b))
								a += 1
							end	
						elseif z[1] == "Grandchild"
							if contains("Great-grandnephew/Great-grandniece", z[2], x[i]) == false
								push!(x2[i], ("Great-grandnephew/Great-grandniece", z[2], b))
								a += 1
							end
						elseif z[1] == "Grandparent"
							if contains("Parent/Parent-in-law", z[2], x[i]) == false
								push!(x2[i], ("Parent/Parent-in-law", z[2], b))
								a += 1
							end
						elseif z[1] == "Nephew/Niece"
							if contains("Grandnephew/Grandniece/Grandnephew-in-law/Grandniece-in-law", z[2], x[i]) == false
								push!(x2[i], ("Grandnephew/Grandniece/Grandnephew-in-law/Grandniece-in-law", z[2], b))
								a += 1
							end
						elseif z[1] == "Parent"
							if contains("Sibling/Sibling-in-law", z[2], x[i]) == false
								push!(x2[i], ("Sibling/Sibling-in-law", z[2], b))
								a += 1
							end
						elseif z[1] == "Sibling"
							if contains("Nephew/Niece/Nephew-in-law/Niece-in-law", z[2], x[i]) == false
								push!(x2[i], ("Nephew/Niece/Nephew-in-law/Niece-in-law", z[2], b))
								a += 1
							end
						end
					end					
				end
			end # if haskey(x, j[2])
		end # for j in x[i]	
	#print("A is:", a)
	#print("\n")
	end
	print("A2 is:", a)
	print("\n")
	x = x2
	if a == 0
		break
	end
end # while


outfh = open("output_actual_and_inferred_relationships.csv", "w")
for pid in keys(x)
	for row in x[pid]
		write(outfh, join((pid, row[1], row[2], row[3]), ","), "\n")
	end
end
close(outfh)


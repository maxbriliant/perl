#!/usr/bin/ruby

#Needs to Change
# C Python C++ Ruby Perl ..


langs = Array(0..9)
langs = "Java", "C#", "SQL", "TypeScript", "Python", "Ruby"
langs = langs.reverse
## TempVariables
newLangs = "" 
iterating = 0

## Personal Rating
ts   = langs.index("TypeScript")
cs   = langs.index("C#")
langs[cs], langs[ts] = langs[ts], langs[cs]
cs   = langs.index("C#")
sql   = langs.index("SQL")
langs[sql], langs[cs] = langs[cs], langs[sql]

## rb py sql cs ts jv -> Java and C# later higher?


for i in langs
	i = i.downcase
	i = i.upcase
	i = i.capitalize
	iterating += 1

	if i == ("Sql" || "sql" || "sql" ) then 
		i = i.upcase 
	end

	if i.include?("s" || "S") then
		letter = i["s"]
		i[letter] = letter.upcase
	end 
	newLangs = i
	printf "%-20s %s\n", newLangs,  iterating 
end

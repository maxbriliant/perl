#/usr/bin/ruby
BEGIN {
mara  = Array.new(3) 		#mara
kara  = Array.new(6) 		#kara
kara  = [4,8,16,96,972,999] 	#devineNumbers 
para  = [] 			#para
mana  = []			#paraCopy
hara  = 2 			### hamiltonianConstant
mara  = 0, 1, hara   		## quBit in Dual  
width = 4
$ram  = 24			 
$merge = $ram * kara.length   #%Modulo for Redundence



#Loading into RAM
def RA(kara, hara, mara, para)
	for ra in (0..$ram) #7141678
		mara = ra(kara, hara, mara, para)
	end
	mara
end

#RA Providing
def ra(kara, hara, mara, para)
	rise = 0
	#Rising through kara
	#kara  = [4,16,512,999]
	for ba in kara
		hara = kara[rise]
		hara = rand(0..kara.length)%2
		rise += 1 % kara.length
		if $merge % rise == 0 
			para.push hara
		end
		#print para
		#end
	end
	mara[2] = hara
	mara
end





## REWRITE ##################
def minPara(para, width) 
	#print para
	ia		   = 0
	arrayCount = 0
	paraWide   = []
	for i in para
		if 		(para[i] == 1 && para[i+1] == 1 ) 
				paraWide[ia] = para[ia]
				ia  += 1
				next
		elsif	(para[i] == 0 && para[i+1] == 0 )
				#print para[i]
				paraWide[ia] = para[ia]
				ia  += 1
				next
		elsif 	(para[i] == 1 && para[i+1] == 0 ) or (para[i] == 0 && para[i+1] == 1 )
				if 		para[i] or para[i+1] == 1
						#paraWide[ia] = 1
						ia  += 1
						next
				elsif   para[i] or para[i+1] == 0
						reset(para)
						ia  += 1
						next
				else next
				end
		else


				paraWide[ia] = ""
				ia  += 1
				next
		end

	end 
	#array = paraWide.map{|e| e ? e : 0}
	#split(paraWide.join())
end
#################################



## Useful Function call -> split(para.join())
def split(str)
  #puts " input string: #{str}"
  s = str.chars.chunk(&:itself).map{|_,a| a.join}.join(", ")
  #puts "output string: #{s}"
  s
end

##Qbit List
def prana(para, width)
	prana = minPara(para, width)
end

def reset(para)
	para += ""
end


def copyPara(para, mana)
	for i in para
		if (i == 1 or i == 0)
			mana << para[i]
		end
	end
end


def manapri(para, mana)
	copyPara(para, mana)
	for i in mana 
		print mana[i]
		if mana.index(i) % 7  == 0 then print "\n" end
	end
end
}


## RA -> Qbit[2]
ra = RA(kara, hara, mara, para)


puts "Calculating Qubit: "
puts ra << "\n"

manapri(para, mana)

#puts para = prana(para, width)


#puts string = split(para.join())

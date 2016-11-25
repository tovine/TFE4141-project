#!/usr/bin/env python

import sys, re

#Helper function - returns the value of the bit at position 'n' of the number 'a'
def getBitAt(a, n):
	if n >= 0 and (a & (1 << (n))) != 0:
		return 1
	else:
		return 0

# Returns a*b mod n
def blakley(a,b,n):
	k=129 # 2^128 is a 129 bit number!
	print('Blakley: ',hex(a),hex(b),hex(n))
	p=0
	for i in range(0,k):              
                p = p << 1
                if getBitAt(a,(k-1-i)):
                        p = p + b
		if p>=n:
			p=p-n
		if p>=n:
			p=p-n
#	assert(p == a*b%n) # This line is useful to include when testing the blakley routine
	return p


# Returns u = a*b*r^-1 (mod n)
def monpro(a,b,n):
	print('monpro: ',a,b,n)
	u=0
	k=128
	for i in range(0,k):
		if getBitAt(a,i): #u=u+a[i]*b
			u = u + b
		if getBitAt(u,0):
			u=u+n
		u=u>>1
	if (u >= n):
		u = u - n
	print('Final result:',hex(u))
	return u

def modexp(m,e,n,r):
        k=128
	x_= blakley(2**128,0x1,n) # = R*mod(n)
	m_ = blakley(2**128,m,n) # r = 2^k = 2^128 always
        for i in range(k-1,-1,-1):
		x_=monpro(x_,x_,n)
		print('x_: ',hex(x_))
		#if e[i]==1:
		if getBitAt(e,i):
			x_=monpro(m_,x_,n)
	x=monpro(x_,1,n)
	return x

print("sys.argv length:", len(sys.argv), sys.argv)
if len(sys.argv) is 5:
	if sys.argv[1] == 'b':
		print(blakley(int(sys.argv[2],0), int(sys.argv[3],0), int(sys.argv[4],0)))
	elif sys.argv[1] == 'mp':
		print(monpro(int(sys.argv[2],0), int(sys.argv[3],0), int(sys.argv[4],0)))
	elif re.match("[0-9]*", sys.argv[1]):
		# We can assume that all input are numeric - run modexp with the given arguments
		result = modexp(int(sys.argv[1],0), int(sys.argv[2],0), int(sys.argv[3],0), int(sys.argv[4],0))
		print(result, hex(result))

elif len(sys.argv) is 4:
	if sys.argv[1] == 'gba':
		print(bin(int(sys.argv[2],0)), getBitAt(int(sys.argv[2],0), int(sys.argv[3],0)))

else:
	print("""Available functions:
	'gba' - getBitAt(n,i), get bit i of the number n
	'b' - blakley(a,b,n)
	'mp' - monpro(a,b,n)
	default: modexp(m,e,n,r)""")

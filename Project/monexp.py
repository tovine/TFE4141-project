#!/usr/bin/env python

import sys, re

#Helper function - returns the value of the bit at position 'n' of the number 'a'
def getBitAt(a, n):
	if n >= 0 and (a & (1 << (n))) != 0:
		return 1
	else:
		return 0

# Returns a*b mod n - seems to work, as long as r is passed as parameter 1
def blakley(a,b,n):
#	k=len(bin(a))-2
	k=max(len(bin(a))-2, len(bin(b))-2)
#	k=128
	print('Blakley: ',hex(a),hex(b),hex(n))
	p=0
	for i in range(0,k): # Python ranges are not inclusive
		p = p << 1
		if getBitAt(a,(k-i-1)):
			p = p + b
		if p>=n:
			p=p-n
		if p>=n:
			p=p-n
		print('Blakley: i=',i, 'p=',hex(p))

	print('Blakley siste p: ', hex(p))
	print('a*b mod n: ', hex(a*b%n))
	assert(p == a*b%n)
	return p


# Returns u = a\*b\*r^-1 (mod n)
def monpro(a,b,n):
	print('monpro: ',a,b,n)
	u=0
	k=len(bin(n))-1
	for i in range(0,k):
		#u=u+a[i]*b
		if getBitAt(a,i):
			u = u + b
		print(bin(u))

		if getBitAt(u,0):
			u=u+n
		print(bin(u))
		u=u>>1
		print(bin(u))
		print('i:', i, 'b:', b, 'u:',u)
	if (u >= n):
		u = u - n
	print('i:', i, 'b:', b, 'u:',u)
	return u

def modexp(m,e,n,r):
	k=len(bin(e))-2
	#m_ = blakley(m,r,n)
	m_ = blakley(r,m,n)
	x_= blakley(r,0x1,n) # = R*mod(n)
	#x_= blakley(0x1,r,n)
	print(m_,x_)
	for i in range(k-1,0,-1):
		x_=monpro(x_,x_,n)
		print('x_: ',hex(x_))
		#if e[i]==1:
		if getBitAt(e,i):
			x_=monpro(m_,x_,n)
	x=monpro(x_,1,n)
	return x

print("sys.argv length:", len(sys.argv), sys.argv)
if len(sys.argv) is 5:
	if re.match("[0-9]", sys.argv[1]):
		# We can assume that all input are numeric - run modexp with the given arguments
		result = modexp(int(sys.argv[1],0), int(sys.argv[2],0), int(sys.argv[3],0), int(sys.argv[4],0))
		print(result, hex(result))
	elif sys.argv[1] == 'b':
		print(blakley(int(sys.argv[2],0), int(sys.argv[3],0), int(sys.argv[4],0)))
	elif sys.argv[1] == 'mp':
		print(monpro(int(sys.argv[2],0), int(sys.argv[3],0), int(sys.argv[4],0)))

elif len(sys.argv) is 4:
	if sys.argv[1] == 'gba':
		print(bin(int(sys.argv[2],0)), getBitAt(int(sys.argv[2],0), int(sys.argv[3],0)))

else:
	print("""Available functions:
	'gba' - getBitAt(n,i), get bit i of the number n
	'b' - blakley(a,b,n)
	'mp' - monpro(a,b,n)
	default: modexp(m,e,n,r)""")

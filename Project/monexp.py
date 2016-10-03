#!/usr/bin/env python

#M= 0x0aaabbbb
#N= 0x819dc6b2
#E= 0x70df64f3
M=19
E=5
N=119
#R= 2**128
R= 2**32
#Result= 0x79114D01
Result=66


print('M=',hex(M))
print('N=',hex(N))
print('E=',hex(E))
print('R=',hex(R))

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


def monpro(a,b,n):
	u=0
	k=len(bin(n))-2
	for i in range(0,k):
		#u=u+a[i]*b
		if (a & (1 << i)) != 0:
			u = u + b

		if (u%2==1):
			u=u+n
		u=u>>1
	return u

def modexp(m,e,n,r):
	k=len(bin(e))-2
	#m_ = blakley(m,r,n)
	m_ = blakley(r,m,n)
	#x_= blakley(r,1,n)
	x_= blakley(r,0x1,n)
	print(m_,x_)
	for i in range(k-1,-1,-1):
		x_=monpro(x_,x_,n)
		print('x_: ',hex(x_))
		#if e[i]==1:
		if (e & (1 << i)) != 0:
			x_=monpro(m_,x_,n)
	x=monpro(x_,1,n)
	return x


print(blakley(6,1,5))
print(blakley(5,5,5))
#print(blakley(M,M,N))

#print(bin(blakley(M,M,N)))
#print(bin(monpro(M,M,N)))
print(hex(modexp(M,E,N,R)))

print('Expected: ', hex(Result))

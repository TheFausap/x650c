import std.stdio;

void oned_add(ref int a, ref int b, ref int d, ref int c, int s_a, int s_b)
{
	if (s_a == 45) {
		a = 9 - a;
	}
	if (s_b == 45) {
		b = 9 - b;
	}
	d = a + b + c;
	if (d>9) {
		d -= 10;
		c = 1;
	} else {
		c = 0;
	}
}

void add1(int[] a)
{
	int[] b;
	b.length = a.length;
	b[$-1] = 43;
	b[$-2] = 1;
	int cc = 0;

	for (long i=a.length-2;i>=0;i--) {
		oned_add(a[i],b[i],a[i],cc,a[$-1],b[$-1]);
	}
}


void comp(int[] a)
{
	for(long i=0;i<a.length-2;i++) {
		a[i] = 9-a[i];
	}
	a[$-2] = 10-a[$-2];
}

void add(int[] a, int[] b)
{
	int cc = 0;
	int cf;

	for (long i=a.length-2;i>=0;i--)
	{
		oned_add(a[i],b[i],a[i],cc,a[$-1],b[$-1]);
		cf = cc;
	}
	writeln(cc);
	writeln(cf);
	if ((a[$-1] == 45) || (b[$-1] == 45)) {
		if (cc == 1) {
			a[$-1] = 43;
			add1(a);
			cc = 0;
		} else {
			comp(a);
			a[$-1] = 45;
		}
	}
}

void main()
{
	int[] n1 = [0,0,0,3,4,5,'-'];
	int[] n2 = [0,0,0,7,7,7,'+'];

	writeln(n1); writeln(n2);

	add(n1,n2);

	writeln(n1);
}

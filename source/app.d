import std.stdio;

int[] distributor;
int[] lower_accumulator;
int[] upper_accumulator;
int[] program_register;
int[] op_register;
int[] address_register;
int[] control_console_sw;

int[][2000] drum;

void getmem()
{
	int ad = 0;

	for(long i=address_register.length-2,j=0;i>=0;i--,j++) {
		ad += address_register[i] * 10^^j;
	}
	switch(ad) {
	case 8000:
		control_console_sw[] = program_register[1..11];
		break;
	case 8001:
		program_register[] = distributor[];
		break;
	case 8002:
		program_register[] = lower_accumulator[];
		break;
	case 8003:
		program_register[1..11] = upper_accumulator[];
		break;
	default:
		program_register = drum[ad];
	}
}

int[] readmem()
{
	int ad = 0;

	for(long i=address_register.length-2,j=0;i>=0;i--,j++) {
		ad += address_register[i] * 10^^j;
	}
	switch(ad) {
	case 8000:
		return control_console_sw[];
	case 8001:
		return distributor[];
	case 8002:
		return lower_accumulator[];
	case 8003:
		return upper_accumulator[];
	default:
		return drum[ad];
	}
}

void writemem(int[] v)
{
	int ad = 0;

	for(long i=address_register.length-2,j=0;i>=0;i--,j++) {
		ad += address_register[i] * 10^^j;
	}
	switch(ad) {
	case 8000:
		control_console_sw[] = v[1..11];
		break;
	case 8001:
		distributor[] = v[];
		break;
	case 8002:
		lower_accumulator[] = v[];
		break;
	case 8003:
		upper_accumulator[] = v[];
		break;
	default:
		drum[ad] = v[];
	}
}

void getop()
{
	op_register = program_register[9..11];
}

void getdaddr()
{
	address_register = program_register[5..9];
}

void getiaddr()
{
	address_register = program_register[1..5];
}

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

void sub1(int[] a)
{
	int[] b;
	b.length = a.length;
	b[$-1] = 45;
	b[$-2] = 1;
	int cc = 0;
	comp(b);
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

int add(int[] a, int[] b)
{
	int cc = 0;

	for (long i=a.length-2;i>=0;i--)
	{
		oned_add(a[i],b[i],a[i],cc,a[$-1],b[$-1]);
	}

	if ((a[$-1] == 45) ^ (b[$-1] == 45)) {
		if (cc == 1) {
			a[$-1] = 43;
			add1(a);
			cc = 0;
		} else {
			add1(a);
			comp(a);
			a[$-1] = 45;
		}
	} else if ((a[$-1] == 45) && (b[$-1] == 45)) {
		comp(a);
	}
	return cc;
}

void opexec()
{
	if (op_register == [1,0]) {
		if (lower_accumulator[$-1] == distributor[$-1]) {
			add(upper_accumulator,distributor);
		} else {
			add(upper_accumulator,distributor);
			comp(lower_accumulator);
			sub1(upper_accumulator);
		}
	} else if (op_register == [1,5]) {
		int cry = add(lower_accumulator,distributor);
		if (cry == 1) {
			add1(upper_accumulator);
		}
	}
}

void microcode()
{
	// phase D
	getmem();
	getop();
	getdaddr();

	// op analysis
	if (op_register == [1,0]) {
		distributor[] = readmem();
	}
	opexec();

	// phase I
	op_register[]=0;
	address_register[]=0;
	getiaddr();

	// then go to phase D
}

void init()
{
	distributor.length=11;
	op_register.length=2;
	address_register.length=11;
	lower_accumulator.length=11;
	upper_accumulator.length=10;
	program_register.length=11;
	control_console_sw.length=10;

	for(int i=0;i<drum.length;i++) {
		drum[i].length=11;
	}

	address_register = [0,0,0,0,0,0,0,0,0,1,'+'];
}

void mywr(int[] a)
{
	char c = 0;

	for(long i=0;i<a.length-1;i++) {
		write(a[i]);
	}
	c = cast(char)a[$-1];
	write(c);
}

void mywru(int[] a)
{
	char c = 0;

	for(long i=0;i<a.length;i++) {
		write(a[i]);
	}
}

void dump()
{
	write("D ");mywr(distributor); writeln();
	write("A ");mywru(upper_accumulator);mywr(lower_accumulator);
	writeln();
	write("P ");mywr(program_register); writeln();
	write("O ");mywr(op_register); writeln();
	write("AD ");mywr(address_register); writeln();
	write("CSW ");mywr(control_console_sw); writeln();
}

void main()
{
	int[] n1 = [0,0,0,3,4,5,'-'];
	int[] n2 = [0,0,0,7,7,7,'-'];

	init();

	drum[1] = [1,0,0,3,4,5,0,1,0,0,'+'];
	drum[100] = [1,1,0,3,4,5,0,1,2,0,'+'];
	drum[345] = [0,0,0,0,0,0,4,6,6,7,'+'];

	microcode();

	dump();
}

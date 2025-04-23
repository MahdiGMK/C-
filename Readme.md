# C~

Authors :

- Maedeh Heidari 400104918
- Mahdi Bahramian 401171593
- Mohammad Alizadeh 401106244

A Simple C-like language

```cpp
// === Variable declarations and assignments ===
int a = 10;
float b = 3.14;
bool c = true;
char d = 'x';
string s = "hello";

// === Arithmetic and logical expressions ===
int e;
e = (a + 5) * 2 - 3 / 1 % 2;
bool f;
f = a > 5 && b <= 10.0 || !c;

// === If-else statement ===
if (f) {
  int abc;
  print(e);
} else {
  print(0);
};

// === While loop ===
while (a < 20) {
  a = a + 1;
};

// === For loop ===
for (a = 0; a < 5; a = a + 1) {
  print(a);
};

// === Struct definition ===
struct Person {
  int age,
  float height
}

Person p = Person{age = 1, height = 12};
p.age = 10 + 12;
p.height = 12.24;

// === Array declaration, initialization, indexing ===
[]int arr;
arr = []int{1, 2, 3};
print(arr[1]);

// === Array in struct
struct City{
    []int postalcodes
}

City c = City{ postalcodes = []int{1 , 2 , 3} };
c.postalcodes = []int{4 , 5 , 6};
c.postalcodes[0] = 0;

// === Nested function calls and definitions ===
int double(int x) {
  return x * 2;
}

int quadruple(int y) {
  return double(double(y));
}

print(quadruple(4));

{
  int z;
  z = 999;
  print(z);
};
```

#include<iostream>
#include<ctime>
#include<sstream>
#include<cstdlib>
using namespace std;



int main(){
srand(time(0));
    ios_base::sync_with_stdio(0);

int n; cin >> n;
cin.ignore();
for(int i=0; i<n; ++i){

    string S;
    getline(cin, S);

    S+= "|";


    int kierownica = rand()%100;
    if(kierownica>74) S+="P|";
    else S+="L|";

    int miejsc = rand()%7+2;
ostringstream ss, ss2;
ss << miejsc;
string str = ss.str();

S+=str;
S+="|";

int waga = rand()%2000 + 650;
ss2 << waga;
string str2 = ss2.str();

S+=str2;
S+="|";


    if(waga>2500)
    {
        S += "C|";
    }
    else S += "O|";

    cout << S << endl;

}


}

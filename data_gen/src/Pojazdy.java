import java.time.LocalDate;
import java.util.Random;

/**
 * Created by Michal Stobierski on 2016-06-04.
 */

public class Pojazdy {

    static int objects = 0;
    static Random rNum = new Random();

    int id_pojazdu;
    String nr_rejestracyjny;
    String data_rejestracji;
    String marka;
    String model;
    String typ;


    public Pojazdy(LocalDate mozliwaRejestracja) {
        id_pojazdu = ++objects;

        data_rejestracji = FunkcjeLosujace.generuj_date(mozliwaRejestracja.toString(), LocalDate.now().toString());

        String[] samochod = Dane.samochody.get(rNum.nextInt(Dane.samochody.size())).split(",");
        marka = samochod[0];
        model = samochod[1];

        if(rNum.nextInt(32) == 0) this.typ = "ciężarowy";
        else this.typ = "osobowy";

        nr_rejestracyjny = "";
        nr_rejestracyjny += Dane.kodyTablic.get(rNum.nextInt(Dane.kodyTablic.size()));
        int dolosuj = 7 - nr_rejestracyjny.length();
        nr_rejestracyjny += " ";

        nr_rejestracyjny += (char)(rNum.nextInt(10) + '0');  // Po kodzie powiatu cyfra
        for (int i = 1; i < dolosuj; ++i) {

            if(rNum.nextInt(2)==1 && (i == 1 || i == dolosuj-1 || i == dolosuj-2)) // zeby wygladaly ladniej ;p
            {
                nr_rejestracyjny += (char)(rNum.nextInt(26) + 'A');   // losowa litera
            }
            else
            {
                nr_rejestracyjny += (char)(rNum.nextInt(10) + '0');   //losowa cyfra
            }
        }
    }

    public int getId_pojazdu() {
        return id_pojazdu;
    }

    @Override
    public String toString() {
        return "(" +
                id_pojazdu +
                ", '" + nr_rejestracyjny +
                "', '" + data_rejestracji +
                "', '" + marka +
                "', '" + model +
                "', '" + typ +
                "')";
    }
}

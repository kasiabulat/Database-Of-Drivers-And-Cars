import java.time.LocalDate;
import java.util.*;

/**
 * Created by Michal Stobierski on 2016-06-03.
 */

public class Kierowca {

    static int objects = 0;
    static Random rNum = new Random();
    static final String URODZENI_OD = "1986-01-01";
    static final String URODZENI_DO = "1997-01-01";
    static final int OCZEKIWANIE = 21;

    int id_kierowcy;
    long pesel;
    String imie;
    String nazwisko;
    String email;
    String nr_telefonu;
    String adres;

    // pola pomocnicze, nie uwzgledniane w krotce
    String data_urodzenia;

    public Kierowca() {

        int plec = rNum.nextInt(2);    // 0 - K, 1 - M

        id_kierowcy = ++objects;

        data_urodzenia = FunkcjeLosujace.generuj_date(URODZENI_OD, URODZENI_DO);
        //System.out.println(data_urodzenia);
        pesel = FunkcjeLosujace.generujPesel(plec, data_urodzenia);

        List<String> personalia = FunkcjeLosujace.generuj_imie_nazwisko(plec);
        imie = personalia.get(0);
        nazwisko = personalia.get(1);

        email = FunkcjeLosujace.generuj_mail(imie, nazwisko);
        nr_telefonu = FunkcjeLosujace.generuj_numer_telefonu();
        adres = FunkcjeLosujace.generuj_adres();


        // Generuj w miare sensowne dane dotyczace kierowcy

        List<String> posiadaneKat = new ArrayList<>();
        posiadaneKat.add("B"); posiadaneKat.add("A"); posiadaneKat.add("C"); posiadaneKat.add("D");

        int ilePrawJazdy = rNum.nextInt(100)+1;
        if(ilePrawJazdy <= 60) ilePrawJazdy = 1;
        else if(ilePrawJazdy <= 80) ilePrawJazdy = 2;
        else if(ilePrawJazdy <= 90) ilePrawJazdy = 3;
        else ilePrawJazdy = 4;

        for (int i = 0; i < ilePrawJazdy; ++i) {
            int ileTeorii = rNum.nextInt(2);
            int ilePraktyk = rNum.nextInt(3);

            // Jakiej kategorii bedzie to prawko
            String kategoria = posiadaneKat.get(i);

            // Wszystkie podejscia do teorii
            WynikiEgzaminow nowyEgz;

            LocalDate orientacyjnaData = LocalDate.parse(data_urodzenia);
            orientacyjnaData = orientacyjnaData.plusYears(18).plusDays(21*(i+4));
            String wynikEgzV = "";
            for (int j = 0; j < ileTeorii; ++j){
                int wynikEgz = rNum.nextInt(4);
                if(wynikEgz < 1) wynikEgzV = "nie stawił się";
                else wynikEgzV = "nie zdał";

                nowyEgz = new WynikiEgzaminow(id_kierowcy, wynikEgzV, orientacyjnaData, "teoria");
                Dane.wynikiEgzaminow.add(nowyEgz);

                orientacyjnaData = nowyEgz.getData().plusDays(OCZEKIWANIE);
            }
            wynikEgzV = "zdał";
            nowyEgz = new WynikiEgzaminow(id_kierowcy, wynikEgzV, orientacyjnaData, "teoria");
            Dane.wynikiEgzaminow.add(nowyEgz);
            orientacyjnaData = nowyEgz.getData().plusDays(OCZEKIWANIE/3);

            // Wszystkie podejscia do praktyki
            for (int j = 0; j < ilePraktyk; ++j){
                int wynikEgz = rNum.nextInt(4);
                if(wynikEgz < 1) wynikEgzV = "nie stawił się";
                else wynikEgzV = "nie zdał";

                nowyEgz = new WynikiEgzaminow(id_kierowcy, wynikEgzV, orientacyjnaData, "praktyka");
                Dane.wynikiEgzaminow.add(nowyEgz);

                orientacyjnaData = nowyEgz.getData().plusDays(OCZEKIWANIE);
            }
            wynikEgzV = "zdał";
            nowyEgz = new WynikiEgzaminow(id_kierowcy, wynikEgzV, orientacyjnaData, "praktyka");
            Dane.wynikiEgzaminow.add(nowyEgz);
            orientacyjnaData = nowyEgz.getData().plusDays(OCZEKIWANIE/2*3);

            // Wygeneruj prawko tej kategorii
            PrawaJazdy nowePJ = new PrawaJazdy(id_kierowcy, orientacyjnaData.toString());
            Dane.prawaJazdy.add(nowePJ);

            // Wygeneruj PJkategorie
            PrawaJazdyKategorie nowePJK = new PrawaJazdyKategorie(nowePJ.getNumer_prawa_jazdy(), kategoria);
            Dane.prawaJazdyKategorie.add(nowePJK);
        }

        // Generowanie pojazdow
        int ilePojazdow = rNum.nextInt(2)+1;
        for (int i = 0; i< ilePojazdow; ++i){
            Pojazdy nowyPojazd = new Pojazdy(LocalDate.parse(data_urodzenia).plusYears(18).plusDays(1));
            Dane.pojazdy.add(nowyPojazd);

            KierowcyPojazdy nowyKP = new KierowcyPojazdy(id_kierowcy, nowyPojazd.getId_pojazdu());
            Dane.kierowcyPojazdy.add(nowyKP);
        }

        // Generowanie otrzymanych mandatow
        int ileMandatow = rNum.nextInt(4);
        for (int i = 0; i < ileMandatow; ++i){
            Mandaty nowyMandat = new Mandaty(id_kierowcy);
            Dane.mandaty.add(nowyMandat);
        }
    }

    public String toString() {
        return "(" +
                "'" + id_kierowcy +
                "', '" + pesel +
                "', '" + imie +
                "', '" + nazwisko +
                "', '" + email +
                "', '" + nr_telefonu +
                "', '" + adres + "'" +
                ")";
    }
}

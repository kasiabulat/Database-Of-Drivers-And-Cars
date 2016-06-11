import java.time.LocalDate;
import java.util.*;

/**
 * Created by Michal Stobierski on 2016-06-03.
 */

class Kierowca {

    private static final Random rNum = new Random();
    private static final String URODZENI_OD = "1986-01-01";
    private static final String URODZENI_DO = "1997-01-01";
    private static final int OCZEKIWANIE = 21;
    private static int objects;
    private final int id_kierowcy;
    private final long pesel;
    private final String imie;
    private final String nazwisko;
    private final String email;
    private final String nr_telefonu;
    private final String adres;

    public Kierowca() {

        final int plec = rNum.nextInt(2);    // 0 - K, 1 - M

        id_kierowcy = ++objects;

        final String data_urodzenia = FunkcjeLosujace.generuj_date(URODZENI_OD, URODZENI_DO);
        //System.out.println(data_urodzenia);
        pesel = FunkcjeLosujace.generujPesel(plec, data_urodzenia);

        final List<String> personalia = FunkcjeLosujace.generuj_imie_nazwisko(plec);
        imie = personalia.get(0);
        nazwisko = personalia.get(1);

        email = FunkcjeLosujace.generuj_mail(imie, nazwisko);
        nr_telefonu = FunkcjeLosujace.generuj_numer_telefonu();
        adres = FunkcjeLosujace.generuj_adres();


        // Generuj w miare sensowne dane dotyczace kierowcy

        final List<String> posiadaneKat = new ArrayList<>();
        posiadaneKat.add("B");
        posiadaneKat.add("A");
        posiadaneKat.add("C");
        posiadaneKat.add("D");

        int ilePrawJazdy = rNum.nextInt(100) + 1;
        if (ilePrawJazdy <= 60) ilePrawJazdy = 1;
        else if (ilePrawJazdy <= 80) ilePrawJazdy = 2;
        else if (ilePrawJazdy <= 90) ilePrawJazdy = 3;
        else ilePrawJazdy = 4;

        for (int i = 0; i < ilePrawJazdy; ++i) {
            final int ileTeorii = rNum.nextInt(2);
            final int ilePraktyk = rNum.nextInt(3);

            // Jakiej kategorii bedzie to prawko
            final String kategoria = posiadaneKat.get(i);

            // Wszystkie podejscia do teorii

            LocalDate orientacyjnaData = LocalDate.parse(data_urodzenia);
            orientacyjnaData = orientacyjnaData.plusYears(18).plusDays(21 * (i + 4));
            String wynikEgzV;
            WynikiEgzaminow nowyEgz;
            for (int j = 0; j < ileTeorii; ++j) {
                final int wynikEgz = rNum.nextInt(4);
                wynikEgzV = wynikEgz < 1 ? "nie stawił się" : "nie zdał";

                nowyEgz = new WynikiEgzaminow(id_kierowcy, wynikEgzV, orientacyjnaData, "teoria");
                Dane.wynikiEgzaminow.add(nowyEgz);

                orientacyjnaData = nowyEgz.getData().plusDays(OCZEKIWANIE);
            }
            wynikEgzV = "zdał";
            nowyEgz = new WynikiEgzaminow(id_kierowcy, wynikEgzV, orientacyjnaData, "teoria");
            Dane.wynikiEgzaminow.add(nowyEgz);
            orientacyjnaData = nowyEgz.getData().plusDays(OCZEKIWANIE / 3);

            // Wszystkie podejscia do praktyki
            for (int j = 0; j < ilePraktyk; ++j) {
                final int wynikEgz = rNum.nextInt(4);
                wynikEgzV = wynikEgz < 1 ? "nie stawił się" : "nie zdał";

                nowyEgz = new WynikiEgzaminow(id_kierowcy, wynikEgzV, orientacyjnaData, "praktyka");
                Dane.wynikiEgzaminow.add(nowyEgz);

                orientacyjnaData = nowyEgz.getData().plusDays(OCZEKIWANIE);
            }
            wynikEgzV = "zdał";
            nowyEgz = new WynikiEgzaminow(id_kierowcy, wynikEgzV, orientacyjnaData, "praktyka");
            Dane.wynikiEgzaminow.add(nowyEgz);
            orientacyjnaData = nowyEgz.getData().plusDays(OCZEKIWANIE / 2 * 3);

            // Wygeneruj prawko tej kategorii
            final PrawaJazdy nowePJ = new PrawaJazdy(id_kierowcy, orientacyjnaData.toString());
            Dane.prawaJazdy.add(nowePJ);

            // Wygeneruj PJkategorie
            final PrawaJazdyKategorie nowePJK = new PrawaJazdyKategorie(nowePJ.getNumer_prawa_jazdy(), kategoria);
            Dane.prawaJazdyKategorie.add(nowePJK);
        }

        // Generowanie pojazdow
        final int ilePojazdow = rNum.nextInt(2) + 1;
        for (int i = 0; i < ilePojazdow; ++i) {
            final Pojazdy nowyPojazd = new Pojazdy(LocalDate.parse(data_urodzenia).plusYears(18).plusDays(1));
            Dane.pojazdy.add(nowyPojazd);

            final KierowcyPojazdy nowyKP = new KierowcyPojazdy(id_kierowcy, nowyPojazd.getId_pojazdu());
            Dane.kierowcyPojazdy.add(nowyKP);
        }

        // Generowanie otrzymanych mandatow
        final int ileMandatow = rNum.nextInt(4);
        for (int i = 0; i < ileMandatow; ++i) {
            final Mandaty nowyMandat = new Mandaty(id_kierowcy);
            Dane.mandaty.add(nowyMandat);
        }
    }

    @Override
    public String toString() {
        return "(\'" + id_kierowcy +
                "', '" + pesel +
                "', '" + imie +
                "', '" + nazwisko +
                "', '" + email +
                "', '" + nr_telefonu +
                "', '" + adres + '\'' +
                ')';
    }
}

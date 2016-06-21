import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

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
    private final char plec;
    private final String email;
    private final String nr_telefonu;
    private final String ulica;
    private final String nr_budynku;
    private final String kod_pocztowy;
    private final int nr_miejscowosci;


    public Kierowca() {

        final int losPlec = rNum.nextInt(2);    // 0 - K, 1 - M

        id_kierowcy = ++objects;

        final String data_urodzenia = FunkcjeLosujace.generuj_date(URODZENI_OD, URODZENI_DO);
        //System.out.println(data_urodzenia);
        pesel = FunkcjeLosujace.generujPesel(losPlec, data_urodzenia);

        final List<String> personalia = FunkcjeLosujace.generuj_imie_nazwisko(losPlec);
        imie = personalia.get(0);
        nazwisko = personalia.get(1);

        if (losPlec == 0) plec = 'K';
        else plec = 'M';

        email = FunkcjeLosujace.generuj_mail(imie, nazwisko);
        nr_telefonu = FunkcjeLosujace.generuj_numer_telefonu();
        ulica = Dane.adresy.get(rNum.nextInt(Dane.adresy.size()));
        nr_budynku = FunkcjeLosujace.generuj_numer_budynku();
        kod_pocztowy = FunkcjeLosujace.generuj_kod_pocztowy();
        nr_miejscowosci = Dane.miejscowosci.get(rNum.nextInt(Dane.miejscowosci.size())).getId_miejscowosci();

        // ------- SKONCZYLEM GENEROWAC PODSTAWOWE DANE KROTKI ---------

        // Generuj w miare sensowne dane dotyczace kierowcy

        int ilePrawJazdy = rNum.nextInt(100) + 1;
        if (ilePrawJazdy <= 75) ilePrawJazdy = 1;
        else if (ilePrawJazdy <= 85) ilePrawJazdy = 2;
        else if (ilePrawJazdy <= 95) ilePrawJazdy = 3;
        else ilePrawJazdy = 4;

        Map<Integer, Boolean> posiadaneJuz = new HashMap<>();

        for (int i = 0; i < ilePrawJazdy; ++i) {
            final int ileTeorii = rNum.nextInt(2);
            final int ilePraktyk = rNum.nextInt(3);

            // Jakiej kategorii bedzie to prawko

            int kategoria;
            if (i == 0) {
                kategoria = 4;  //niech kazdy ma B ;p
                posiadaneJuz.put(4, true);
            } else {
                kategoria = rNum.nextInt(8) + 1;
                while (posiadaneJuz.containsKey(kategoria)) {
                    kategoria = rNum.nextInt(8) + 1;
                }
            }

            // Wszystkie podejscia do teorii
            LocalDate orientacyjnaData = LocalDate.parse(data_urodzenia);
            orientacyjnaData = orientacyjnaData.plusYears(18).plusDays(21 * (i + 4));
            String wynikEgzV;
            Egzamin nowyEgz;

            for (int j = 0; j < ileTeorii; ++j) {
                final int wynikEgz = rNum.nextInt(4);
                wynikEgzV = wynikEgz < 1 ? "nie stawil sie" : "nie zdal";

                nowyEgz = new Egzamin(orientacyjnaData, "teoria", kategoria, id_kierowcy, wynikEgzV);
                Dane.egzaminy.add(nowyEgz);

                orientacyjnaData = nowyEgz.getData_przeprowadzenia().plusDays(OCZEKIWANIE);
            }
            wynikEgzV = "zdal";
            nowyEgz = new Egzamin(orientacyjnaData, "teoria", kategoria, id_kierowcy, wynikEgzV);
            Dane.egzaminy.add(nowyEgz);
            orientacyjnaData = nowyEgz.getData_przeprowadzenia().plusDays(OCZEKIWANIE / 3);

            // Wszystkie podejscia do praktyki
            for (int j = 0; j < ilePraktyk; ++j) {
                final int wynikEgz = rNum.nextInt(4);
                wynikEgzV = wynikEgz < 1 ? "nie stawil sie" : "nie zdal";

                nowyEgz = new Egzamin(orientacyjnaData, "praktyka", kategoria, id_kierowcy, wynikEgzV);
                Dane.egzaminy.add(nowyEgz);

                orientacyjnaData = nowyEgz.getData_przeprowadzenia().plusDays(OCZEKIWANIE);
            }
            wynikEgzV = "zdal";
            nowyEgz = new Egzamin(orientacyjnaData, "praktyka", kategoria, id_kierowcy, wynikEgzV);
            Dane.egzaminy.add(nowyEgz);
            orientacyjnaData = nowyEgz.getData_przeprowadzenia().plusDays(OCZEKIWANIE / 2 * 3);

            // Wygeneruj prawko tej kategorii
            final PrawoJazdy nowePJ = new PrawoJazdy(id_kierowcy, orientacyjnaData.toString());
            Dane.prawaJazdy.add(nowePJ);

            // Wygeneruj PJkategorie
            final PrawaJazdyKategorie nowePJK = new PrawaJazdyKategorie(nowePJ.getNumer_prawa_jazdy(), kategoria, nowePJ.getData_wydania());
            Dane.prawa_jazdy_kategorie_praw_jazdy.add(nowePJK);
        }

        // Generowanie pojazdow
        final int ilePojazdow = rNum.nextInt(2) + 1;
        for (int i = 0; i < ilePojazdow; ++i) {
            final Pojazd nowyPojazd = new Pojazd(LocalDate.parse(data_urodzenia).plusYears(18).plusDays(1));
            Dane.pojazdy.add(nowyPojazd);

            final KierowcyPojazdy nowyKP = new KierowcyPojazdy(id_kierowcy, nowyPojazd.getId_pojazdu());
            Dane.kierowcyPojazdy.add(nowyKP);
        }

        // Generowanie otrzymanych mandatow
        Mandat.generuj_mandaty(rNum.nextInt(4), id_kierowcy);
    }

    @Override
    public String toString() {
        return "(" +
                id_kierowcy +
                ", " + pesel +
                ", '" + imie + '\'' +
                ", '" + nazwisko + '\'' +
                ", '" + plec + '\'' +
                ", '" + email + '\'' +
                ", '" + nr_telefonu + '\'' +
                ", '" + ulica + '\'' +
                ", '" + nr_budynku + '\'' +
                ", '" + kod_pocztowy + '\'' +
                ", " + nr_miejscowosci +
                ')';
    }
}

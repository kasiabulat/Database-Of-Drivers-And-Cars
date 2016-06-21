import java.time.LocalDate;
import java.time.Period;
import java.util.Random;

/**
 * Created by Michal Stobierski on 2016-06-04.
 */

class Mandat {

    private static final Random rNum = new Random();
    private static int objects;
    private final int id_mandatu;
    private final int id_kierowcy;
    private final int id_wystawiajacego;
    private final int id_wykroczenia;
    String data_wystawienia;

    public Mandat(final int id_kierowcy) {
        this.id_kierowcy = id_kierowcy;
        id_mandatu = ++objects;

        id_wystawiajacego = Dane.mandatyWystawiajacy.get(rNum.nextInt(Dane.mandatyWystawiajacy.size())).getId_wystawiajacego();
        id_wykroczenia = Dane.wykroczenia.get(rNum.nextInt(Dane.wykroczenia.size())).getId_wykroczenia();
    }

    public static void generuj_mandaty(int ilosc, int id_kierowcy) {
        // Generowanie otrzymanych mandatow
        for (int i = 0; i < ilosc; ++i) {
            final Mandat nowyMandat = new Mandat(id_kierowcy);
            for (PrawoJazdy tmp : Dane.prawaJazdy) {
                if (tmp.getId_wlasciciela() == id_kierowcy) {
                    LocalDate teraz = LocalDate.now();
                    //System.out.println(tmp.getData_wydania() + " " + teraz);

                    int lat = Period.between(tmp.getData_wydania(), teraz).getYears();
                    int mies = Period.between(tmp.getData_wydania(), teraz).getMonths();
                    int dni = Period.between(tmp.getData_wydania(), teraz).getDays();
                    // System.out.println(dni);
                    nowyMandat.data_wystawienia = tmp.getData_wydania().plusDays(rNum.nextInt(lat * 360 + mies * 30 + dni)).toString();
                }
            }
            Dane.mandaty.add(nowyMandat);
        }
    }

    @Override
    public String toString() {
        return "(" +
                id_mandatu +
                ", " + id_kierowcy +
                ", " + id_wystawiajacego +
                ", " + id_wykroczenia +
                ", " + id_wykroczenia +
                ", '" + data_wystawienia +
                "')";
    }
}

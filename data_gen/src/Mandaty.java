import java.util.Random;

/**
 * Created by Michal Stobierski on 2016-06-04.
 */

class Mandaty {

    private static int objects;
    private static final Random rNum = new Random();

    private final int id_mandatu;
    private final int id_kierowcy;
    private final int id_wystawiajacego;
    private final int id_wykroczenia;

    public Mandaty(final int id_kierowcy) {
        this.id_kierowcy = id_kierowcy;
        id_mandatu = ++objects;

        id_wystawiajacego = Dane.mandatyWystawiajacy.get(rNum.nextInt(Dane.mandatyWystawiajacy.size())).getId_wystawiajacego();
        id_wykroczenia = Dane.wykroczenia.get(rNum.nextInt(Dane.wykroczenia.size())).getId_wykroczenia();
    }

    @Override
    public String toString() {
        return "(" +
                id_mandatu +
                ", " + id_kierowcy +
                ", " + id_wystawiajacego +
                ", " + id_wykroczenia +
                ')';
    }
}

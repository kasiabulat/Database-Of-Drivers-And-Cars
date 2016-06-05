import java.util.Random;

/**
 * Created by Michal Stobierski on 2016-06-04.
 */

public class Mandaty {

    static int objects = 0;
    static Random rNum = new Random();

    int id_mandatu;
    int id_kierowcy;
    int id_wystawiajacego;
    int id_wykroczenia;

    public Mandaty(int id_kierowcy) {
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
                ")";
    }
}

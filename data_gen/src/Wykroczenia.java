import java.util.HashMap;
import java.util.Map;
import java.util.Random;

/**
 * Created by Michal Stobierski on 2016-06-04.
 */

class Wykroczenia {

    private static int objects;
    private static final Random rNum = new Random();
    private static final Map<String, Boolean> wytworzoneWykroczenia = new HashMap<>();


    private final int id_wykroczenia;
    private final String opis;
    private final double wysokosc_grzywny;
    private final int punkty_karne;

    public Wykroczenia() {
        id_wykroczenia = ++objects;

        String[] wykroczenie = Dane.taryfikator.get(rNum.nextInt(Dane.taryfikator.size())).split(";");
        while(wytworzoneWykroczenia.containsKey(wykroczenie[0])){
            wykroczenie = Dane.taryfikator.get(rNum.nextInt(Dane.taryfikator.size())).split(";");
        }
        opis = wykroczenie[0];
        punkty_karne = Integer.parseInt(wykroczenie[1]);
        wysokosc_grzywny = Integer.parseInt(wykroczenie[2]);
        wytworzoneWykroczenia.put(opis, true);
    }

    public int getId_wykroczenia() {
        return id_wykroczenia;
    }

    @Override
    public String toString() {
        return "(" +
                id_wykroczenia +
                ", '" + opis +
                "', " + wysokosc_grzywny +
                ", " + punkty_karne +
                ')';
    }
}

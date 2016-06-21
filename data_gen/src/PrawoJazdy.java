import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

/**
 * Created by Michal Stobierski on 2016-06-04.
 */

class PrawoJazdy {

    private static final Random rNum = new Random();
    private static final Map<Integer, Boolean> posiadaMiedzynarodowe = new HashMap<>();
    private final int id_wlasciciela;
    private final String data_wydania;
    private String numer_prawa_jazdy;
    private boolean miedzynarodowe;

    public PrawoJazdy(final int id_wlasciciela, final String data_wydania) {
        this.id_wlasciciela = id_wlasciciela;
        this.data_wydania = data_wydania;

        numer_prawa_jazdy = "";
        for (int i = 0; i < 5; ++i) {
            numer_prawa_jazdy += (char) (rNum.nextInt(10) + '0');
        }
        numer_prawa_jazdy += "/";
        numer_prawa_jazdy += data_wydania.substring(2, 4);
        numer_prawa_jazdy += "/";
        for (int i = 0; i < 4; ++i) {
            numer_prawa_jazdy += (char) (rNum.nextInt(10) + '0');
        }
        miedzynarodowe = posiadaMiedzynarodowe.containsKey(id_wlasciciela);
        if (rNum.nextInt(8) == 0) {
            miedzynarodowe = true;
            posiadaMiedzynarodowe.put(id_wlasciciela, true);
            Dane.prawaJazdy.stream().filter(i -> i.id_wlasciciela == id_wlasciciela).forEach(i -> i.miedzynarodowe = true);
        }

    }

    public String getNumer_prawa_jazdy() {
        return numer_prawa_jazdy;
    }

    public LocalDate getData_wydania() {
        LocalDate ret = LocalDate.parse(data_wydania);
        return ret;
    }

    public int getId_wlasciciela() {
        return id_wlasciciela;
    }

    @Override
    public String toString() {
        return "(\'" + numer_prawa_jazdy +
                "', " + id_wlasciciela +
                ", '" + data_wydania +
                "', " + miedzynarodowe +
                ')';
    }
}

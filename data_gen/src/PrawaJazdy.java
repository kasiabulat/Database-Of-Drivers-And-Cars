import java.util.*;

/**
 * Created by Michal Stobierski on 2016-06-04.
 */

public class PrawaJazdy {

    static Random rNum = new Random();
    public static Map<Integer, Boolean> posiadaMiedzynarodowe = new HashMap<>();

    String numer_prawa_jazdy;
    int id_wlasciciela;
    String data_wydania;
    boolean miedzynarodowe;

    public PrawaJazdy(int id_wlasciciela, String data_wydania) {
        this.id_wlasciciela = id_wlasciciela;
        this.data_wydania = data_wydania;

        numer_prawa_jazdy = "";
        for (int i = 0; i < 5; ++i){
            numer_prawa_jazdy += (char)(rNum.nextInt(10) + '0');
        }
        numer_prawa_jazdy += "/";
        numer_prawa_jazdy += data_wydania.substring(2, 4);
        numer_prawa_jazdy += "/";
        for (int i = 0; i < 4; ++i){
            numer_prawa_jazdy += (char)(rNum.nextInt(10) + '0');
        }
        miedzynarodowe = posiadaMiedzynarodowe.containsKey(id_wlasciciela);
        if(rNum.nextInt(8) == 0) {
            miedzynarodowe = true;
            posiadaMiedzynarodowe.put(id_wlasciciela, true);
            for (PrawaJazdy i: Dane.prawaJazdy){
                if(i.id_wlasciciela == id_wlasciciela){
                    i.miedzynarodowe = true;
                }
            }
        }

    }

    public String getNumer_prawa_jazdy() {
        return numer_prawa_jazdy;
    }

    @Override
    public String toString() {
        return "(" +
                "'" + numer_prawa_jazdy +
                "', " + id_wlasciciela +
                ", '" + data_wydania +
                "', " + miedzynarodowe +
                ")";
    }
}

/**
 * Created by Michal Stobierski on 2016-06-12.
 */

public class Firma {

    int id_firmy;
    String nip;
    String regon;
    String numerkrs;
    String nazwa_firmy;
    String email;
    String nr_telefonu;
    String ulica;
    String nr_budynku;
    String kod_pocztowy;
    int nr_miejscowosci;

    public Firma(String add) {

        String[] dane = add.split("[|]");

        id_firmy = new Integer(dane[0]);
        nazwa_firmy = dane[1];
        nr_miejscowosci = Miejscowosc.getId_miejscowosci(dane[2]);
        kod_pocztowy = dane[3];
        ulica = dane[4];
        nr_budynku = dane[5];
        nr_telefonu = dane[6];
        email = dane[7];
        nip = dane[8];
        regon = dane[9];
        if (dane.length > 10) numerkrs = dane[10];
        else numerkrs = "";
    }

    @Override
    public String toString() {
        return "(" +
                id_firmy +
                ", '" + nip + '\'' +
                ", '" + regon + '\'' +
                ", '" + numerkrs + '\'' +
                ", '" + nazwa_firmy + '\'' +
                ", '" + email + '\'' +
                ", '" + nr_telefonu + '\'' +
                ", '" + ulica + '\'' +
                ", '" + nr_budynku + '\'' +
                ", '" + kod_pocztowy + '\'' +
                ", " + nr_miejscowosci +
                ')';
    }
}



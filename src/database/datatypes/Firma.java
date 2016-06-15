package database.datatypes;

/**
 * Created by rafalbyczek on 15.06.16.
 */
public class Firma {
    private int id_firmy;
    private String nip;
    private String regon;
    private String numerkrs;
    private String nazwa_firmy;
    private String email;
    private String nr_telefonu;
    private String ulica;
    private String nr_budynku;
    private String kod_pocztowy;
    private String miejscowosc;

    public Firma(final int id_firmy,final String nip,final String regon,final String numerkrs,final String nazwa_firmy,final String email,final String nr_telefonu,final String ulica,final String nr_budynku,final String kod_pocztowy,final String miejscowosc) {
        this.id_firmy = id_firmy;
        this.nip = nip;
        this.regon = regon;
        this.numerkrs = numerkrs;
        this.nazwa_firmy = nazwa_firmy;
        this.email = email;
        this.nr_telefonu = nr_telefonu;
        this.ulica = ulica;
        this.nr_budynku = nr_budynku;
        this.kod_pocztowy = kod_pocztowy;
        this.miejscowosc = miejscowosc;
    }

    public String getMiejscowosc() {
        return miejscowosc;
    }

    public void setMiejscowosc(final String miejscowosc) {
        this.miejscowosc = miejscowosc;
    }

    public int getId_firmy() {
        return id_firmy;
    }

    public void setId_firmy(final int id_firmy) {
        this.id_firmy = id_firmy;
    }

    public String getNip() {
        return nip;
    }

    public void setNip(final String nip) {
        this.nip = nip;
    }

    public String getRegon() {
        return regon;
    }

    public void setRegon(final String regon) {
        this.regon = regon;
    }

    public String getNumerkrs() {
        return numerkrs;
    }

    public void setNumerkrs(final String numerkrs) {
        this.numerkrs = numerkrs;
    }

    public String getNazwa_firmy() {
        return nazwa_firmy;
    }

    public void setNazwa_firmy(final String nazwa_firmy) {
        this.nazwa_firmy = nazwa_firmy;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(final String email) {
        this.email = email;
    }

    public String getNr_telefonu() {
        return nr_telefonu;
    }

    public void setNr_telefonu(final String nr_telefonu) {
        this.nr_telefonu = nr_telefonu;
    }

    public String getUlica() {
        return ulica;
    }

    public void setUlica(final String ulica) {
        this.ulica = ulica;
    }

    public String getNr_budynku() {
        return nr_budynku;
    }

    public void setNr_budynku(final String nr_budynku) {
        this.nr_budynku = nr_budynku;
    }

    public String getKod_pocztowy() {
        return kod_pocztowy;
    }

    public void setKod_pocztowy(final String kod_pocztowy) {
        this.kod_pocztowy = kod_pocztowy;
    }

}

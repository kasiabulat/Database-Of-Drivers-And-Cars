package database.datatypes;

import java.math.BigDecimal;

/**
 * Created by Kamil Rajtar on 03.06.16.
 */
public class Offence {
    private String imię_sprawcy;
    private String nazwisko_sprawcy;
    private String opis;
    private BigDecimal grzywna;
    private int punkty_karne;

    public Offence(final String imię_sprawcy, final String nazwisko_sprawcy, final String opis, final BigDecimal grzywna, final int punkty_karne) {
        this.imię_sprawcy = imię_sprawcy;
        this.nazwisko_sprawcy = nazwisko_sprawcy;
        this.opis = opis;
        this.grzywna = grzywna;
        this.punkty_karne = punkty_karne;
    }

    public String getImię_sprawcy() {
        return imię_sprawcy;
    }

    public void setImię_sprawcy(final String imię_sprawcy) {
        this.imię_sprawcy = imię_sprawcy;
    }

    public String getNazwisko_sprawcy() {
        return nazwisko_sprawcy;
    }

    public void setNazwisko_sprawcy(final String nazwisko_sprawcy) {
        this.nazwisko_sprawcy = nazwisko_sprawcy;
    }

    public String getOpis() {
        return opis;
    }

    public void setOpis(final String opis) {
        this.opis = opis;
    }

    public BigDecimal getGrzywna() {
        return grzywna;
    }

    public void setGrzywna(final BigDecimal grzywna) {
        this.grzywna = grzywna;
    }

    public int getPunkty_karne() {
        return punkty_karne;
    }

    public void setPunkty_karne(final int punkty_karne) {
        this.punkty_karne = punkty_karne;
    }
}

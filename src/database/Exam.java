package database;

import java.time.LocalDate;

/**
 Created by Kamil Rajtar on 03.06.16. */
public class Exam
{
	private int id_egzaminu;
	private LocalDate data_przeprowadzenia;
	private String typ;
	private String nazwa_ośrodka;
	private String adres_ośrodka;
	private String imię_egzaminatora;
	private String nazwisko_egzaminatora;
	private String imię_zdającego;
	private String nazwisko_zdającego;
	private String wynik;

	Exam(final int id_egzaminu,final LocalDate data_przeprowadzenia,final String typ,final String nazwa_ośrodka,final String adres_ośrodka,final String imię_egzaminatora,final String nazwisko_egzaminatora,final String imię_zdającego,final String nazwisko_zdającego,final String wynik)
	{
		this.id_egzaminu=id_egzaminu;
		this.data_przeprowadzenia=data_przeprowadzenia;
		this.typ=typ;
		this.nazwa_ośrodka=nazwa_ośrodka;
		this.adres_ośrodka=adres_ośrodka;
		this.imię_egzaminatora=imię_egzaminatora;
		this.nazwisko_egzaminatora=nazwisko_egzaminatora;
		this.imię_zdającego=imię_zdającego;
		this.nazwisko_zdającego=nazwisko_zdającego;
		this.wynik=wynik;
	}

	public int getId_egzaminu()
	{
		return id_egzaminu;
	}

	public void setId_egzaminu(final int id_egzaminu)
	{
		this.id_egzaminu=id_egzaminu;
	}

	public LocalDate getData_przeprowadzenia()
	{
		return data_przeprowadzenia;
	}

	public void setData_przeprowadzenia(final LocalDate data_przeprowadzenia)
	{
		this.data_przeprowadzenia=data_przeprowadzenia;
	}

	public String getTyp()
	{
		return typ;
	}

	public void setTyp(final String typ)
	{
		this.typ=typ;
	}

	public String getNazwa_ośrodka()
	{
		return nazwa_ośrodka;
	}

	public void setNazwa_ośrodka(final String nazwa_ośrodka)
	{
		this.nazwa_ośrodka=nazwa_ośrodka;
	}

	public String getAdres_ośrodka()
	{
		return adres_ośrodka;
	}

	public void setAdres_ośrodka(final String adres_ośrodka)
	{
		this.adres_ośrodka=adres_ośrodka;
	}

	public String getImię_egzaminatora()
	{
		return imię_egzaminatora;
	}

	public void setImię_egzaminatora(final String imię_egzaminatora)
	{
		this.imię_egzaminatora=imię_egzaminatora;
	}

	public String getNazwisko_egzaminatora()
	{
		return nazwisko_egzaminatora;
	}

	public void setNazwisko_egzaminatora(final String nazwisko_egzaminatora)
	{
		this.nazwisko_egzaminatora=nazwisko_egzaminatora;
	}

	public String getImię_zdającego()
	{
		return imię_zdającego;
	}

	public void setImię_zdającego(final String imię_zdającego)
	{
		this.imię_zdającego=imię_zdającego;
	}

	public String getNazwisko_zdającego()
	{
		return nazwisko_zdającego;
	}

	public void setNazwisko_zdającego(final String nazwisko_zdającego)
	{
		this.nazwisko_zdającego=nazwisko_zdającego;
	}

	public String getWynik()
	{
		return wynik;
	}

	public void setWynik(final String wynik)
	{
		this.wynik=wynik;
	}
}

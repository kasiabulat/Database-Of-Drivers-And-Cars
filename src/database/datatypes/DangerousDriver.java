package database.datatypes;

/**
 Created by Kamil Rajtar on 14.06.16. */
public class DangerousDriver
{
	private String imię;
	private String nazwisko;
	private Integer ilość_mandatów;
	private Integer suma_punktów_karnych;

	public DangerousDriver(String imię,String nazwisko,Integer ilość_mandatów,Integer suma_punktów_karnych)
	{
		this.imię=imię;
		this.nazwisko=nazwisko;
		this.ilość_mandatów=ilość_mandatów;
		this.suma_punktów_karnych=suma_punktów_karnych;
	}

	public String getImię()
	{
		return imię;
	}

	public void setImię(String imię)
	{
		this.imię=imię;
	}

	public String getNazwisko()
	{
		return nazwisko;
	}

	public void setNazwisko(String nazwisko)
	{
		this.nazwisko=nazwisko;
	}

	public Integer getIlość_mandatów()
	{
		return ilość_mandatów;
	}

	public void setIlość_mandatów(Integer ilość_mandatów)
	{
		this.ilość_mandatów=ilość_mandatów;
	}

	public Integer getSuma_punktów_karnych()
	{
		return suma_punktów_karnych;
	}

	public void setSuma_punktów_karnych(Integer suma_punktów_karnych)
	{
		this.suma_punktów_karnych=suma_punktów_karnych;
	}
}

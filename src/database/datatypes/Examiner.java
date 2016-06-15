package database.datatypes;

/**
 Created by Kamil Rajtar on 15.06.16. */
public class Examiner
{
	String imię;
	String nazwisko;
	Integer ilu_zdało;

	public Examiner(String imię,String nazwisko,Integer ilu_zdało)
	{
		this.imię=imię;
		this.nazwisko=nazwisko;
		this.ilu_zdało=ilu_zdało;
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

	public Integer getIlu_zdało()
	{
		return ilu_zdało;
	}

	public void setIlu_zdało(Integer ilu_zdało)
	{
		this.ilu_zdało=ilu_zdało;
	}
}

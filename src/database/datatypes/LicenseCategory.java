package database.datatypes;

/**
 Created by Kamil Rajtar on 15.06.16. */
public class LicenseCategory
{
	public final String name;
	public final Integer count;

	public LicenseCategory(final String name,final Integer count)
	{
		this.name=name;
		this.count=count;
	}
}

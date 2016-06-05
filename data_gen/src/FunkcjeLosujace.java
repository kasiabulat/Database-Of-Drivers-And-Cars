import java.text.Normalizer;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Random;
import java.util.regex.Pattern;

/**
 * Created by Michal Stobierski on 2016-06-03.
 */

class FunkcjeLosujace {

    private static final Random rNum = new Random();
    private static final Pattern Ł=Pattern.compile("ł");

    static long generujPesel(final int plec,final String data_urodzenia){
        // Generowanie prawdziwego PESELu

        long temp = Integer.parseInt(data_urodzenia.substring(2, 4));  // rok urodzenia
        long pesel=0;
        pesel += temp;
        long suma_kontrolna=0;
        suma_kontrolna +=temp/10+ temp%10*3;

        temp = Integer.parseInt(data_urodzenia.substring(5, 7));   // miesiac urodzenia
        pesel *= 100; pesel += temp;
        suma_kontrolna +=temp/10*7 + temp%10*9;

        temp = Integer.parseInt(data_urodzenia.substring(8, 10));   // dzien urodzenia
        pesel *= 100; pesel += temp;
        suma_kontrolna +=temp/10+ temp%10*3;

        temp = rNum.nextInt(100);  // byle co
        pesel *= 100; pesel += temp;
        suma_kontrolna +=temp/10*7 + temp%10*9;

        temp = rNum.nextInt(99) + 1;  // znowu
        if(plec==0&&temp%2==1||plec==1&&temp%2==0) temp--;    // plec jest 10 cyfra peselu, zalezy od parzystosci

        pesel *= 100; pesel += temp;
        suma_kontrolna +=temp/10+ temp%10*3;

        pesel *= 10; pesel +=(10 -suma_kontrolna%10)%10;

        return pesel;
        // uff, koniec PESELU
    }

    static List<String> generuj_imie_nazwisko(final int plec)
    {
        final List<String> res = new ArrayList<>();
        if(plec == 0)
        {
            res.add(Dane.imionaDamskie.get(rNum.nextInt(Dane.imionaDamskie.size())));
            res.add(Dane.nazwiskaDamskie.get(rNum.nextInt(Dane.nazwiskaDamskie.size())));
        }
        else
        {
            res.add(Dane.imionaMeskie.get(rNum.nextInt(Dane.imionaMeskie.size())));
            res.add(Dane.nazwiskaMeskie.get(rNum.nextInt(Dane.nazwiskaMeskie.size())));
        }
        return res;
    }

    static String generuj_mail(){
        String email = "";
        for (int i = 0, fin = rNum.nextInt(9)+3; i < fin; ++i) {
            email += (char)(rNum.nextInt(26) + 'a');
        }
        email += Dane.domenyMailowe.get(rNum.nextInt(Dane.domenyMailowe.size()));
        return email;
    }

    private static String deAccent(final CharSequence str) {
        String nfdNormalizedString = Normalizer.normalize(str, Normalizer.Form.NFD);
        final Pattern pattern = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
        nfdNormalizedString =Ł.matcher(nfdNormalizedString).replaceAll("l");
        return pattern.matcher(nfdNormalizedString).replaceAll("");
    }

    static String generuj_mail(final String imie,final String nazwisko){
        String email = "";
        email += nazwisko.toLowerCase(Locale.ENGLISH);
        email += ".";
        email += imie.toLowerCase(Locale.ENGLISH);
        email += Dane.domenyMailowe.get(rNum.nextInt(Dane.domenyMailowe.size()));

        email = deAccent(email);    // magia ze stackoverflow q 1008802
        return email;
    }

    static String generuj_numer_telefonu(){
        String res = "";
        res += (char)(rNum.nextInt(4) + '5');   // cyfra 5-8
        for (int i = 1; i < 9; ++i) {
            res += (char)(rNum.nextInt(10) + '0');  // dowolna cyfra
        }
        return res;
    }

    static String generuj_adres()
    {
        String adres=Dane.adresy.get(rNum.nextInt(Dane.adresy.size()));
        adres += " ";
        for (int i = 0; i < rNum.nextInt(2)+1; ++i){
            adres += (char)(rNum.nextInt(10) + '0');    // dowolna cyfra
        }
        adres += "/";
        adres += (char)(rNum.nextInt(9) + '1');
        for (int i = 0; i < rNum.nextInt(3); ++i){
            adres += (char)(rNum.nextInt(10) + '0');    // dowolna cyfra
        }
        adres += ", ";
        for (int i = 0; i < 2; ++i){
            adres += (char)(rNum.nextInt(10) + '0');    // dowolna cyfra
        }
        adres += "-";
        for (int i = 0; i < 3; ++i){
            adres += (char)(rNum.nextInt(10) + '0');    // dowolna cyfra
        }
        adres += " ";
        adres += Dane.nazwyMiast.get(rNum.nextInt(Dane.nazwyMiast.size()));
        return adres;
    }

    static String generuj_date(final CharSequence s,final CharSequence e){
        //String s = "2016-05-30";
        //String e = "2016-06-10";
        final LocalDate start = LocalDate.parse(s);
        final LocalDate end = LocalDate.parse(e);
        final int days = start.until(end).getDays();
        final int years = start.until(end).getYears();
        final int months = start.until(end).getMonths();

        /*List<LocalDate> totalDates = new ArrayList<>();
        while (!start.isAfter(end)) {
            totalDates.add(start);
            start = start.plusDays(1);
        }
        System.out.println(totalDates);*/

        return start.plusDays(rNum.nextInt(days+365*years+30*months)).toString();
    }

}

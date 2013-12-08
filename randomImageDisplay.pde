/*************************************************************************************
Random Image Display
This sketch takes a search term, and every two seconds, pulls in a random image matching
that search term from google images and displays it.  
I wrapped up the "get random image" function into a nice, encapsulated function, randomGoogleImage,
so it's easy to reuse.  


*************************************************************************************/



import java.net.HttpURLConnection;    // required for HTML download
import java.net.URL;                  // ditto, etc...
import java.net.URLConnection;
import java.net.URLEncoder;
import java.io.InputStreamReader;     // used to get our raw HTML source
import java.io.File;
PImage img=null;
String search="rickroll";

void setup()
{
  size(500,500);
}

void draw()
{
  background(0);
  if(img!=null)
    image(img,width/2-img.width/2,height/2-img.height/2);
  if((millis()/1000)%2==0)
    img=randomGoogleImage(search, 20);
}

//this function returns a PImage of a random image matching the string searchTerm, based on google images' search results.  
//The results argument specifies how many results to pull in -- more results take longer
PImage randomGoogleImage(String searchTerm, int results)
{
int numSearches = results/20;                 // how many searches to do (limited by Google to 20 images each) 
String fileSize = "10mp";             // specify file size in mexapixels - S/M/L not figured out yet :)
boolean saveImages = true;            // save the resulting images?

String source = null;                 // string to save raw HTML source code
String[] imageLinks = new String[0];  // array to save URLs to - written to file at the end
int offset = 0;                       // we can only 20 results at a time - increment to get total # of searches
int imgCount = 0;                     // count saved images for creating filenames
String outputTerm;
PImage img=null;

  // format spaces in URL to avoid problems; convert to _ for saving
  outputTerm = searchTerm.replaceAll(" ", "_");
  searchTerm = searchTerm.replaceAll(" ", "%20");


  // run search as many times as specified
  println("Retreiving image links (" + fileSize + ")...\n");
  for (int search=0; search<numSearches; search++) {
    
    // let us know where we're at in the process
    print("  " + ((search+1)*20) + " / " + (numSearches*20) + ":");

    // get Google image search HTML source code; mostly built from PhyloWidget example:
    // http://code.google.com/p/phylowidget/source/browse/trunk/PhyloWidget/src/org/phylowidget/render/images/ImageSearcher.java
    print(" downloading...");
    try {
      URL query = new URL("http://images.google.com/images?gbv=1&start=" + offset + "&q=" + searchTerm + "&tbs=isz:lt,islt:" + fileSize);
      HttpURLConnection urlc = (HttpURLConnection) query.openConnection();                                // start connection...
      urlc.setInstanceFollowRedirects(true);
      urlc.setRequestProperty("User-Agent", "");
      urlc.connect();
      BufferedReader in = new BufferedReader(new InputStreamReader(urlc.getInputStream()));               // stream in HTTP source to file
      StringBuffer response = new StringBuffer();
      char[] buffer = new char[1024];
      while (true) {
        int charsRead = in.read(buffer);
        if (charsRead == -1) {
          break;
        }
        response.append(buffer, 0, charsRead);
      }
      in.close();                                                                                         // close input stream (also closes network connection)
      source = response.toString();
    }
    // any problems connecting? let us know
    catch (Exception e) {
      e.printStackTrace();
    }

    // extract image URLs only, starting with 'imgurl'
    println(" parsing...");
    if (source != null) {
      // built partially from: http://www.mkyong.com/regular-expressions/how-to-validate-image-file-extension-with-regular-expression
      String[][] m = matchAll(source, "<img[^>]+src\\s*=\\s*['\"]([^'\"]+)['\"][^>]*>");    // (?i) means case-insensitive
      if (m != null) {                                                                          // did we find a match?
        for (int i=0; i<m.length; i++) {                                                        // iterate all results of the match
          imageLinks = append(imageLinks, m[i][1]);                                             // add links to the array**
        }
      }
      else
        println("no match");
    }

    // ** here we get the 2nd item from each match - this is our 'group' containing just the file URL and extension

    // update offset by 20 (limit imposed by Google)
    offset += 20;
  }

    String link=imageLinks[(int)random(imageLinks.length)];

      // run in a 'try' in case we can't connect to an image
      try {
        img = loadImage(link, "jpeg");
      }
      catch (Exception e) {
        println("    error downloading image, skipping...\n");    // likely a NullPointerException
      }

      // looking for something fancier? try: 
      // http://www.avajava.com/tutorials/lessons/how-do-i-save-an-image-from-a-url-to-a-file.html
    return img;
}


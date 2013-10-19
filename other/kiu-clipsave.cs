/*
 * User:   kiu - Salvatore Agostino Romeo
 * Date:   02/02/2006
 * Time:   13.05
 * e-mail:   romeo84@hotmail.com
 * 
 */

using System;
using System.Windows.Forms;
using System.Drawing;

namespace DefaultNamespace
{
   /// <summary>
   /// Save images from clipboard.
   /// </summary>
   public class GetClip
   {
      public static void Main()
      {
         if (Clipboard.GetDataObject() != null)
         {
            IDataObject data = Clipboard.GetDataObject();
            
            if (data.GetDataPresent(DataFormats.Bitmap))
               {
                  Image image = (Image)data.GetData(DataFormats.Bitmap,true);
                  image.Save("image.png",System.Drawing.Imaging.ImageFormat.Png);
                  image.Save("image.jpg",System.Drawing.Imaging.ImageFormat.Jpeg);
               }
         }
         
      }
   }
}
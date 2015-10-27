# daseinCapabilityScanner
Parses dasein cloud implementations and creates a html capability matrix.

To Use:

##### Step 1:
Clone the dasein repo's you want to include in the capability scan into the same director producing a ls as such....
```
  > ls -1
  dasein-cloud-atmos
  dasein-cloud-azurearm
  dasein-cloud-azurepack
  dasein-cloud-brightbox
  dasein-cloud-cloudsigma
  dasein-cloud-cloudstack
  dasein-cloud-digitalocean
  dasein-cloud-flexiant
  dasein-cloud-gogrid
  dasein-cloud-google
  dasein-cloud-ibm
  dasein-cloud-joyent
  dasein-cloud-nimbula
  dasein-cloud-openstack
  dasein-cloud-opsource
  dasein-cloud-rackspace
  dasein-cloud-softlayer
  dasein-cloud-terremark
  dasein-cloud-tier3
  dasein-cloud-vcloud
  dasein-cloud-virtustream
  dasein-cloud-vsphere
  dasein-cloud-zimory
```


##### Step 2:
./capaoilityScanner.pl > daseinCapabilities.html

You will need to copy GridviewScroll.css, gridviewScroll.min.js, and the Images directory and its content to the directory where you end up homing daseinCapabilities.html


<A HREF="http://htmlpreview.github.io/?https://github.com/unwin/daseinCapabilityScanner/blob/master/daseinCapabilities.html">daseinCapabilities.html</A>

GridViewScroll taken from http://gridviewscroll.aspcity.idv.tw/
---------------------------------------------------------------
/*
 * GridViewScroll with jQuery v0.9.6.8
 * http://gridviewscroll.aspcity.idv.tw/

 * Copyright (c) 2012 Likol Lee
 * Released under the MIT license

 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

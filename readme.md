# zh-cn readme
## 坐标转换 for postgis

1. GCJ-02, WGS 1984, BD坐标转换

  使用网上流传的公式，BD和02转换近似精确，84到02只能说是马马虎虎

2. Geometry级别的坐标转换

  现在只求勉强能用，不求正确率及效率。目前支持点线面和Multi点线面，用法见代码头部注释

3. 免责声明
  
  copyleft，使用或者不使用、带来的一切后果用户自行负责

----------------
# en readme
## pg-cnxy, chinese coordinate convertor for PostgreSQL/PostGIS

### 1. Coordinate systems in China 

There are several variants of **WGS1984/EPSG:4326** spatial res sys in China. 

#### 1.1 GCJ-02

The authority **DO NOT ALLOW** public maps directly use original lon/lat, data should be transformed into the so called **GCJ-02** coord sys.
Too make things easy, you can think it as a WGS 1984 coord sys with some *random* offset. Most web maps in China use the GCJ-02 coord sys, this had coused a lot of problems in the past. To make our application work well, it is suggested to use GCJ-02 in China. Of course we do not know the precise formula of the *random* offset, but people had struggled for years and got an approximation of it (https://blog.genglinxiao.com/中国地图坐标偏移算法破解小史/). Here the code in this repo is an pl/pgsql implementation for postgis.

If you need precise transformation, you can use the Web Service API of Tecent Map or AMap.

#### 1.2 BD

Baidu Map uses another transformd coord sys, noted as **BD** here. It is based on GCJ-02, the precise approximation of the transormation formula had been found. There are still plenty of light-weighted apps build on Baidu Map. 

There exists other similar coord sys, however we do not have to know much, for they have few users now, and will have fewer in the future. 


### 2. Geometry converter

Precise or not, points are easy to be transformed between WGS 1984, GCJ-02 and BD. The same work for geometry is not quite easy. Replace coords in WKT seems to be a good idea, but why should we write a robust parser? I tried to modify proj.4 or gdal, but gave up, it won't be a standard part of them, users have to compile it first. So pl/pgsql is a good choice. The pgsql file here support polygon, line, point and the collection geometry of them. 

# Disclaimer of Warranty

This a copyleft program. If necessary, it use the disclaimer of GPL (http://www.gnu.org/licenses/gpl.html) as its disclaimer.

    THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM “AS IS” WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.








int ax; //x-size
int ay; //y-size
boolean[][] h, v, r; //horizontal, vertical, road
float sy; //x-side length
float sx; //x-side length
int x; //current x-coordinate
int y; //current y-coordinate
ArrayList<Integer> px=new ArrayList<Integer>(); //previous x-coordinates
ArrayList<Integer> py=new ArrayList<Integer>(); //previous y-coordinates
boolean fin=false;

void setup() {
  size(900, 900);
  colorMode(RGB, 1);
  frameRate(60);
  ax=38;
  ay=38;
  h=new boolean[ax][ay-1];
  v=new boolean[ax-1][ay];
  r=new boolean[ax][ay];
  r[0][0]=true;
  x=0;
  y=0;
  sx=(float)width/(ax+2);
  sy=(float)height/(ay+2);
  px.add(0);
  py.add(0);
  show();
}

void draw() {
  for (int i=0; i<3; i++) {
    if (!fin) {
      step();
      if (x==0&&y==0) {
        fin=true;
        show();
        saveFrame("map2.jpg");
      }
    }
  }
  show();
  if (fin) {
    int[] far=far(x, y);
    noStroke();
    fill(1, 0, 1);
    //rect(sx*(far[0]+1.25), sy*(far[1]+1.25), sx/2+1, sy/2+1);
    ArrayList<Integer>[] way=way(x, y);
    if (max(sx, sy)>10) {
      strokeWeight(3);
    } else {
      strokeWeight(1);
    }
    stroke(1, 0, 1);
    for (int i=0; i<way[0].size()-1; i++) {
      line(sx*(way[0].get(i)+1.5), sy*(way[1].get(i)+1.5), sx*(way[0].get(i+1)+1.5), sy*(way[1].get(i+1)+1.5));
    }
  }
}

void keyPressed() {
  if (fin) {
    switch (keyCode) {
    case 39:
      if (!hv(x, y, 0)) {
        go(0);
      }
      break;
    case 40:
      if (!hv(x, y, 1)) {
        go(1);
      }
      break;
    case 37:
      if (!hv(x, y, 2)) {
        go(2);
      }
      break;
    case 38:
      if (!hv(x, y, 3)) {
        go(3);
      }
      break;
    case 32:
      println(dis(x, y));
      int min=1000000000;
      int best=0;
      if (!hv(x, y, 0)) {
        int dis=dis(x+1, y);
        if (dis<min) {
          min=dis;
          best=0;
        }
      }
      if (!hv(x, y, 1)) {
        int dis=dis(x, y+1);
        if (dis<min) {
          min=dis;
          best=1;
        }
      }
      if (!hv(x, y, 2)) {
        int dis=dis(x-1, y);
        if (dis<min) {
          min=dis;
          best=2;
        }
      }
      if (!hv(x, y, 3)) {
        int dis=dis(x, y-1);
        if (dis<min) {
          min=dis;
          best=3;
        }
      }
      if (dis(x, y)!=0) {
        go(best);
      }
      break;
    }
    show();
  }
}

void step() {
  int dir=-1;
  ArrayList<Integer> d=new ArrayList<Integer>();
  for (int i=0; i<4; i++) {
    if (!hv(x, y, i)&&!back(x, y, i)&&!rr(x, y, i)) {
      d.add(i);
    }
  }
  if (d.size()==0) {
    int max=-1;
    int best=-1;
    for (int i=0; i<4; i++) {
      if (!hv(x, y, i)&&!back(x, y, i)) {
        int dis=dis(x, y, i);
        if (dis>max) {
          max=dis;
          best=i;
        }
      }
    }
    if (best!=-1) {
      d.add(best);
    }
  }
  if (d.size()==0) {
    for (int i=0; i<4; i++) {
      if (back(x, y, i)) {
        dir=i;
      }
    }
  } else {
    dir=d.get(floor(random(d.size())));
  }
  go(dir);
  for (int i=0; i<4; i++) {
    if (i!=(dir+2)%4) {
      if (!r[x][y]) {
        if (rr(x, y, i)) {
          sethv(x, y, i);
        }
      }
    }
  }
  r[x][y]=true;
}

void show() {
  background(1);
  noStroke();
  for (int i=0; i<ax; i++) {
    for (int j=0; j<ay; j++) {
      if (r[i][j]) {
        fill(1);
      } else {
        fill(0);
      }
      rect(sx*(i+1), sy*(j+1), sx, sy);
    }
  }
  noStroke();
  fill(1, 0, 0);
  rect(sx*(x+1.25), sy*(y+1.25), sx/2+1, sy/2+1);
  //rect(sx*(ax+0.25), sy*(ay+0.25), sx/2+1, sy/2+1);
  stroke(0, 0, 1);
  if (sx>10) {
    strokeWeight(3);
  } else {
    strokeWeight(1);
  }
  for (int i=0; i<ax-1; i++) {
    for (int j=0; j<ay; j++) {
      if (v[i][j]) {
        line(sx*(i+2), sy*(j+1), sx*(i+2), sy*(j+2));
      }
    }
  }
  if (sy>10) {
    strokeWeight(3);
  } else {
    strokeWeight(1);
  }
  for (int i=0; i<ax; i++) {
    for (int j=0; j<ay-1; j++) {
      if (h[i][j]) {
        line(sx*(i+1), sy*(j+2), sx*(i+2), sy*(j+2));
      }
    }
  }
  stroke(0, 0, 1);
  strokeWeight(3);
  noFill();
  rect(sx, sy, sx*ax, sy*ay);
}

int[] far(int x, int y) {
  boolean[][] changed=new boolean[ax][ay];
  for (int i=0; i<ax; i++) {
    for (int j=0; j<ay; j++) {
      changed[i][j]=false;
    }
  }
  changed[x][y]=true;
  ArrayList<Integer> xs=new ArrayList<Integer>();
  ArrayList<Integer> ys=new ArrayList<Integer>();
  xs.add(x);
  ys.add(y);
  boolean allChanged=false;
  int d=0;
  while (!allChanged) {
    allChanged=true;
    ArrayList<Integer> nxs=new ArrayList<Integer>();
    ArrayList<Integer> nys=new ArrayList<Integer>();
    for (int i=0; i<xs.size(); i++) {
      for (int dir=0; dir<4; dir++) {
        if (!hv(xs.get(i), ys.get(i), dir)) {
          int nx=0;
          int ny=0;
          switch(dir) {
          case 0:
            nx=xs.get(i)+1;
            ny=ys.get(i);
            break;
          case 1:
            nx=xs.get(i);
            ny=ys.get(i)+1;
            break;
          case 2:
            nx=xs.get(i)-1;
            ny=ys.get(i);
            break;
          case 3:
            nx=xs.get(i);
            ny=ys.get(i)-1;
            break;
          }
          if (!changed[nx][ny]) {
            allChanged=false;
            changed[nx][ny]=true;
            nxs.add(nx);
            nys.add(ny);
          }
        }
      }
    }
    if (nxs.size()==0) {
      println(d);
      return new int[]{xs.get(0), ys.get(0)};
    }
    xs.clear();
    ys.clear();
    xs.addAll(nxs);
    ys.addAll(nys);
    d++;
  }
  //System.err.print("Unreachable endPosition");
  return null;
}

int dis(int x, int y) {
  int[][] distanceMatrix=new int[ax][ay];
  for (int i=0; i<ax; i++) {
    for (int j=0; j<ay; j++) {
      distanceMatrix[i][j]=0;
    }
  }
  distanceMatrix[x][y]=1;
  ArrayList<Integer> xs=new ArrayList<Integer>();
  ArrayList<Integer> ys=new ArrayList<Integer>();
  xs.add(x);
  ys.add(y);
  int d=1;
  if (x==floor(mouseX/sx-1)&&y==floor(mouseY/sy-1)) {
    return 0;
  }
  boolean allChanged=false;
  while (!allChanged) {
    allChanged=true;
    ArrayList<Integer> nxs=new ArrayList<Integer>();
    ArrayList<Integer> nys=new ArrayList<Integer>();
    for (int i=0; i<xs.size(); i++) {
      for (int dir=0; dir<4; dir++) {
        if (!hv(xs.get(i), ys.get(i), dir)) {
          int nx=0;
          int ny=0;
          switch(dir) {
          case 0:
            nx=xs.get(i)+1;
            ny=ys.get(i);
            break;
          case 1:
            nx=xs.get(i);
            ny=ys.get(i)+1;
            break;
          case 2:
            nx=xs.get(i)-1;
            ny=ys.get(i);
            break;
          case 3:
            nx=xs.get(i);
            ny=ys.get(i)-1;
            break;
          }
          if (distanceMatrix[nx][ny]==0) {
            allChanged=false;
            distanceMatrix[nx][ny]=d;
            nxs.add(nx);
            nys.add(ny);
            if (nx==floor(mouseX/sx-1)&&ny==floor(mouseY/sy-1)) {
              return d;
            }
          }
        }
      }
    }
    xs.clear();
    ys.clear();
    xs.addAll(nxs);
    ys.addAll(nys);
    d++;
  }
  //System.err.print("Unreachable endPosition");
  return -1;
}

//TODO: finish this
ArrayList[][] ways(int x, int y) {
  Waay[][] waay=new Waay[ax][ay];


  int[][] distanceMatrix=new int[ax][ay];
  for (int i=0; i<ax; i++) {
    for (int j=0; j<ay; j++) {
      distanceMatrix[i][j]=0;
    }
  }
  distanceMatrix[x][y]=1;
  ArrayList<Integer> xs=new ArrayList<Integer>();
  ArrayList<Integer> ys=new ArrayList<Integer>();
  xs.add(x);
  ys.add(y);
  int d=1;
  boolean allChanged=false;
  while (!allChanged) {
    allChanged=true;
    ArrayList<Integer> nxs=new ArrayList<Integer>();
    ArrayList<Integer> nys=new ArrayList<Integer>();
    for (int i=0; i<xs.size(); i++) {
      for (int dir=0; dir<4; dir++) {
        if (!hv(xs.get(i), ys.get(i), dir)) {
          int nx=0;
          int ny=0;
          switch(dir) {
          case 0:
            nx=xs.get(i)+1;
            ny=ys.get(i);
            break;
          case 1:
            nx=xs.get(i);
            ny=ys.get(i)+1;
            break;
          case 2:
            nx=xs.get(i)-1;
            ny=ys.get(i);
            break;
          case 3:
            nx=xs.get(i);
            ny=ys.get(i)-1;
            break;
          }
          if (distanceMatrix[nx][ny]==0) {
            allChanged=false;
            distanceMatrix[nx][ny]=d;
            nxs.add(nx);
            nys.add(ny);
          }
        }
      }
    }
    xs.clear();
    ys.clear();
    xs.addAll(nxs);
    ys.addAll(nys);
    d++;
  }
  return null;
}

class Waay {
  ArrayList<int[]> list;

  Waay() {
    list=new ArrayList<int[]>();
  }
}

ArrayList[] way(int x, int y) {
  ArrayList<Integer> xs=new ArrayList<Integer>();
  ArrayList<Integer> ys=new ArrayList<Integer>();
  int cux=x;
  int cuy=y;
  xs.add(cux);
  ys.add(cuy);
  while (dis(cux, cuy)>0) {
    int min=1000000000;
    int best=0;
    if (!hv(cux, cuy, 0)) {
      int dis=dis(cux+1, cuy);
      if (dis<min) {
        min=dis;
        best=0;
      }
    }
    if (!hv(cux, cuy, 1)) {
      int dis=dis(cux, cuy+1);
      if (dis<min) {
        min=dis;
        best=1;
      }
    }
    if (!hv(cux, cuy, 2)) {
      int dis=dis(cux-1, cuy);
      if (dis<min) {
        min=dis;
        best=2;
      }
    }
    if (!hv(cux, cuy, 3)) {
      int dis=dis(cux, cuy-1);
      if (dis<min) {
        min=dis;
        best=3;
      }
    }
    switch(best) {
    case 0:
      cux++;
      break;
    case 1:
      cuy++;
      break;
    case 2:
      cux--;
      break;
    case 3:
      cuy--;
      break;
    }
    xs.add(cux);
    ys.add(cuy);
  }
  return new ArrayList[]{xs, ys};
}

int dis(int i, int j, int k) {
  if (!((i==ax-1&&k==0)||(j==ay-1&&k==1)||(i==0&&k==2)||(j==0&&k==3))) {
    switch(k) {
    case 0:
      for (int d=px.size()-1; d>=0; d--) {
        if (px.get(d)==i+1&&py.get(d)==j) {
          return px.size()-d;
        }
      }
      break;
    case 1:
      for (int d=px.size()-1; d>=0; d--) {
        if (px.get(d)==i&&py.get(d)==j+1) {
          return px.size()-d;
        }
      }
      break;
    case 2:
      for (int d=px.size()-1; d>=0; d--) {
        if (px.get(d)==i-1&&py.get(d)==j) {
          return px.size()-d;
        }
      }
      break;
    case 3:
      for (int d=px.size()-1; d>=0; d--) {
        if (px.get(d)==i&&py.get(d)==j-1) {
          return px.size()-d;
        }
      }
      break;
    }
  }
  return -1;
}

boolean hv(int i, int j, int k) {
  if ((i==ax-1&&k==0)||(j==ay-1&&k==1)||(i==0&&k==2)||(j==0&&k==3)) {
    return true;
  }
  switch(k) {
  case 0:
    return v[i][j];
  case 1:
    return h[i][j];
  case 2:
    return v[i-1][j];
  case 3:
    return h[i][j-1];
  }
  return false;
}

boolean rr(int i, int j, int k) {
  if ((i==ax-1&&k==0)||(j==ay-1&&k==1)||(i==0&&k==2)||(j==0&&k==3)) {
    return true;
  }
  switch(k) {
  case 0:
    return r[i+1][j];
  case 1:
    return r[i][j+1];
  case 2:
    return r[i-1][j];
  case 3:
    return r[i][j-1];
  }
  return false;
}

boolean back(int i, int j, int k) {
  switch(k) {
  case 0:
    return i+1==px.get(px.size()-1)&&j==py.get(px.size()-1);
  case 1:
    return i==px.get(px.size()-1)&&j+1==py.get(px.size()-1);
  case 2:
    return i-1==px.get(px.size()-1)&&j==py.get(px.size()-1);
  case 3:
    return i==px.get(px.size()-1)&&j-1==py.get(px.size()-1);
  }
  return false;
}

void go(int k) {
  px.add(x);
  py.add(y);
  switch(k) {
  case 0:
    x++;
    break;
  case 1:
    y++;
    break;
  case 2:
    x--;
    break;
  case 3:
    y--;
    break;
  }
}

void sethv(int i, int j, int k) {
  if (!((i==ax-1&&k==0)||(j==ay-1&&k==1)||(i==0&&k==2)||(j==0&&k==3))) {
    switch(k) {
    case 0:
      v[i][j]=true;
      break;
    case 1:
      h[i][j]=true;
      break;
    case 2:
      v[i-1][j]=true;
      break;
    case 3:
      h[i][j-1]=true;
      break;
    }
  }
}

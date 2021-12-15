use std::ops::{Index, IndexMut};

#[allow(dead_code)]
#[derive(Debug)]
pub enum GridError {
    IndicesOutOfBounds(usize, usize),
}

#[derive(Debug)]
pub struct Grid<T> {
    data: Vec<T>,
    rows_num: usize,
    cols_num: usize,
}

#[allow(dead_code)]
impl<T> Grid<T> {
    pub fn new() -> Self {
        Self {
            data: vec![],
            rows_num: 0,
            cols_num: 0,
        }
    }

    pub fn get(&self, row: usize, col: usize) -> Option<&T> {
        self.get_data_index(row, col).map(|i| &self.data[i])
    }

    pub fn get_mut(&mut self, row: usize, col: usize) -> Option<&mut T> {
        self.get_data_index(row, col)
            .map(move |i| &mut self.data[i])
    }

    pub fn set(&mut self, row: usize, column: usize, value: T) -> Result<(), GridError> {
        self.get_mut(row, column)
            .map(|target| {
                *target = value;
            })
            .ok_or_else(|| GridError::IndicesOutOfBounds(row, column))
    }

    pub fn iter_cell(&self) -> impl Iterator<Item = ((usize, usize), &T)> + '_ {
        (0..self.rows_num).flat_map(move |row| {
            (0..self.cols_num).map(move |col| {
                (
                    (row, col),
                    self.get(row, col).expect("Iter cell should success."),
                )
            })
        })
    }

    fn get_data_index(&self, row: usize, col: usize) -> Option<usize> {
        if row < self.rows_num && col < self.cols_num {
            Some(row * self.rows_num + col)
        } else {
            None
        }
    }
}

impl<T> Default for Grid<T> {
    fn default() -> Self {
        Self::new()
    }
}

impl<T> Index<(usize, usize)> for Grid<T> {
    type Output = T;

    fn index(&self, (row, col): (usize, usize)) -> &Self::Output {
        self.get(row, col)
            .unwrap_or_else(|| panic!("Index out of bounds! row: {}, col: {}", row, col))
    }
}

impl<T> IndexMut<(usize, usize)> for Grid<T> {
    fn index_mut(&mut self, (row, col): (usize, usize)) -> &mut Self::Output {
        match self.get_mut(row, col) {
            Some(x) => x,
            None => (|| panic!("Index out of bounds! row: {}, col: {}", row, col))(),
        }
    }
}

impl<T> Index<(i32, i32)> for Grid<T> {
    type Output = T;

    fn index(&self, (x, y): (i32, i32)) -> &Self::Output {
        if x.is_negative() || y.is_negative() {
            panic!("Coordinate is negative x: {}, y: {}", x, y)
        } else {
            match self.get(y as usize, x as usize) {
                Some(x) => x,
                None => (|| panic!("Coordinate out of bounds x: {}, y: {}", x, y))(),
            }
        }
    }
}

impl<T> IndexMut<(i32, i32)> for Grid<T> {
    fn index_mut(&mut self, (x, y): (i32, i32)) -> &mut Self::Output {
        if x.is_negative() || y.is_negative() {
            panic!("Coordinate is negative x: {}, y: {}", x, y)
        } else {
            match self.get_mut(y as usize, x as usize) {
                Some(x) => x,
                None => (|| panic!("Coordinate out of bounds x: {}, y: {}", x, y))(),
            }
        }
    }
}

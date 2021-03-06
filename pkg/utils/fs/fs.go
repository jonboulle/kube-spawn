/*
Copyright 2017 Kinvolk GmbH

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package fs

import (
	"bytes"
	"io"
	"os"
	"path/filepath"

	"github.com/pkg/errors"
)

func Exists(path string) bool {
	if fi, err := os.Stat(path); os.IsNotExist(err) {
		return false
	} else {
		if !fi.IsDir() && !fi.Mode().IsRegular() {
			return false
		}
	}
	return true
}

func Create(path string, data io.Reader) error {
	dir := filepath.Dir(path)
	if err := os.MkdirAll(dir, os.FileMode(0755)); err != nil {
		return errors.Wrapf(err, "error creating directory %q", dir)
	}
	// assume we are creating a directory
	if data == nil {
		return nil
	}
	f, err := os.OpenFile(path, os.O_RDWR|os.O_CREATE|os.O_TRUNC, 0755)
	if err != nil {
		return errors.Wrapf(err, "error creating %q", path)
	}
	defer f.Close()
	if _, err := io.Copy(f, data); err != nil {
		return errors.Wrapf(err, "error writing %q", path)
	}
	return nil
}

func CreateBytes(path string, data []byte) error {
	buf := bytes.NewBuffer(data)
	return Create(path, buf)
}

func CreateDir(path string) error {
	// make sure path is passed along with a trailing slash
	// otherwise Create() will not create it
	return Create(path+"/", nil)
}

func Copy(src, dst string) error {
	f, err := os.OpenFile(src, os.O_RDONLY, 0755)
	if err != nil {
		return err
	}
	return Create(dst, f)
}
